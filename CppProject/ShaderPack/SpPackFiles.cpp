#include "SpPackFiles.hpp"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QTextCodec>

#include <zip.h>

namespace ShaderPacks
{
	namespace
	{
		// Shaderpack stored as a folder on disk
		class DirPackFiles : public PackFiles
		{
		public:
			QString root; // Path of the "shaders" folder

			bool Exists(const QString& path) const override
			{
				return QFileInfo(root + "/" + NormalizePackPath(path)).isFile();
			}

			bool Read(const QString& path, QByteArray& data) const override
			{
				QFile file(root + "/" + NormalizePackPath(path));
				if (!file.open(QFile::ReadOnly))
					return false;
				data = file.readAll();
				return true;
			}

			QStringList Files() const override
			{
				QStringList list;
				QDir rootDir(root);
				QDirIterator it(root, QDir::Files, QDirIterator::Subdirectories);
				while (it.hasNext())
					list.append(rootDir.relativeFilePath(it.next()));
				return list;
			}
		};

		// Shaderpack stored in a zip archive
		class ZipPackFiles : public PackFiles
		{
		public:
			zip_t* archive = nullptr;
			QString prefix; // Path of the shaders folder inside the archive, including trailing slash
			QHash<QString, zip_uint64_t> entries; // normalized path relative to shaders -> entry index

			~ZipPackFiles() override
			{
				if (archive)
					zip_close(archive);
			}

			bool Exists(const QString& path) const override
			{
				return entries.contains(NormalizePackPath(path));
			}

			bool Read(const QString& path, QByteArray& data) const override
			{
				auto it = entries.constFind(NormalizePackPath(path));
				if (it == entries.constEnd())
					return false;

				zip_stat_t st;
				zip_stat_init(&st);
				if (zip_stat_index(archive, it.value(), 0, &st) != 0)
					return false;

				zip_file_t* file = zip_fopen_index(archive, it.value(), 0);
				if (!file)
					return false;

				data.resize((int)st.size);
				zip_int64_t read = zip_fread(file, data.data(), st.size);
				zip_fclose(file);
				if (read < 0)
					return false;
				data.resize((int)read);
				return true;
			}

			QStringList Files() const override
			{
				return entries.keys();
			}
		};
	}

	std::unique_ptr<PackFiles> PackFiles::Open(const QString& path, QString* error)
	{
		QFileInfo info(path);

		if (info.isDir())
		{
			QString shadersDir;
			if (QFileInfo(path + "/shaders").isDir())
				shadersDir = path + "/shaders";
			else
			{
				// Allow one level of nesting, e.g. "Pack/PackName/shaders"
				QDir dir(path);
				for (const QString& sub : dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
				{
					if (QFileInfo(path + "/" + sub + "/shaders").isDir())
					{
						shadersDir = path + "/" + sub + "/shaders";
						break;
					}
				}
			}

			if (shadersDir.isEmpty())
			{
				if (error)
					*error = "No \"shaders\" folder found in " + path;
				return nullptr;
			}

			auto pack = std::make_unique<DirPackFiles>();
			pack->root = shadersDir;
			pack->name = info.fileName();
			pack->location = path;
			return pack;
		}

		if (info.isFile() && info.suffix().toLower() == "zip")
		{
			int err = 0;
			QByteArray pathData = QFile::encodeName(path);
			zip_t* archive = zip_open(pathData.constData(), ZIP_RDONLY, &err);
			if (!archive)
			{
				if (error)
					*error = "Could not open zip file " + path;
				return nullptr;
			}

			auto pack = std::make_unique<ZipPackFiles>();
			pack->archive = archive;
			pack->name = info.fileName();
			pack->location = path;

			// Find the shaders folder, preferring the shallowest one
			zip_int64_t num = zip_get_num_entries(archive, 0);
			QString bestPrefix;
			int bestDepth = 1000;
			for (zip_int64_t i = 0; i < num; i++)
			{
				const char* name = zip_get_name(archive, (zip_uint64_t)i, ZIP_FL_ENC_GUESS);
				if (!name)
					continue;
				QString entry = QString::fromUtf8(name).replace('\\', '/');
				QStringList parts = entry.split('/');
				for (int p = 0; p < parts.size() - 1 && p < 2; p++)
				{
					if (parts[p] == "shaders" && p < bestDepth)
					{
						bestDepth = p;
						bestPrefix = QStringList(parts.mid(0, p + 1)).join('/') + "/";
					}
				}
			}

			if (bestPrefix.isEmpty())
			{
				if (error)
					*error = "No \"shaders\" folder found in " + path;
				return nullptr;
			}

			pack->prefix = bestPrefix;
			for (zip_int64_t i = 0; i < num; i++)
			{
				const char* name = zip_get_name(archive, (zip_uint64_t)i, ZIP_FL_ENC_GUESS);
				if (!name)
					continue;
				QString entry = QString::fromUtf8(name).replace('\\', '/');
				if (!entry.startsWith(bestPrefix) || entry.endsWith('/'))
					continue;
				pack->entries[NormalizePackPath(entry.mid(bestPrefix.size()))] = (zip_uint64_t)i;
			}

			return pack;
		}

		if (error)
			*error = path + " is not a folder or zip file";
		return nullptr;
	}

	QString PackFiles::ReadText(const QString& path) const
	{
		QByteArray data;
		if (!Read(path, data))
			return QString();

		// Strip UTF-8 BOM
		if (data.startsWith("\xEF\xBB\xBF"))
			data = data.mid(3);

		QTextCodec::ConverterState state;
		QString text = QTextCodec::codecForName("UTF-8")->toUnicode(data.constData(), data.size(), &state);
		if (state.invalidChars > 0)
			text = QString::fromLatin1(data);

		text.remove(QChar(0));
		return text;
	}

	bool PackFiles::DirExists(const QString& dir) const
	{
		QString prefix = NormalizePackPath(dir) + "/";
		for (const QString& file : Files())
			if (file.startsWith(prefix))
				return true;
		return false;
	}

	QString IncludeResolver::ParseInclude(const QString& line, const QString& currentFile)
	{
		static QRegularExpression re("^\\s*#\\s*include\\s+[\"<]([^\">]+)[\">]");
		QRegularExpressionMatch match = re.match(line);
		if (!match.hasMatch())
			return QString();

		QString target = match.captured(1).trimmed();
		if (target.startsWith('/'))
			return NormalizePackPath(target);
		return NormalizePackPath(PackPathDir(currentFile) + "/" + target);
	}

	const QStringList* IncludeResolver::Lines(const QString& path) const
	{
		QString norm = NormalizePackPath(path);
		auto it = cache.constFind(norm);
		if (it != cache.constEnd())
			return &it.value();

		QString text = files.ReadText(norm);
		if (text.isNull())
			return nullptr;

		cache[norm] = text.split(QRegularExpression("\r\n|\r|\n"));
		return &cache[norm];
	}

	void IncludeResolver::FlattenInto(const QString& path, QString& out, QStringList& stack, const LineTransform& transform, QStringList* errors) const
	{
		const QStringList* lines = Lines(path);
		if (!lines)
		{
			if (errors)
				errors->append("Missing include file " + path);
			out += "#error Missing include file " + path + "\n";
			return;
		}

		stack.append(path);
		for (int l = 0; l < lines->size(); l++)
		{
			QString line = transform ? transform(path, l, lines->at(l)) : lines->at(l);
			if (line.contains("include"))
			{
				QString inc = ParseInclude(line, path);
				if (!inc.isNull())
				{
					if (stack.contains(inc))
					{
						if (errors)
							errors->append("Recursive include of " + inc + " in " + path);
						out += "\n";
						continue;
					}
					FlattenInto(inc, out, stack, transform, errors);
					continue;
				}
			}
			out += line;
			out += '\n';
		}
		stack.removeLast();
	}

	QString IncludeResolver::Flatten(const QString& path, const LineTransform& transform, QStringList* errors) const
	{
		if (!Lines(path))
			return QString();

		QString out;
		QStringList stack;
		FlattenInto(NormalizePackPath(path), out, stack, transform, errors);
		return out;
	}

	QStringList IncludeResolver::Reachable(const QStringList& starts) const
	{
		QStringList result;
		QStringList queue;
		for (const QString& s : starts)
			queue.append(NormalizePackPath(s));

		while (!queue.isEmpty())
		{
			QString file = queue.takeFirst();
			if (result.contains(file))
				continue;
			const QStringList* lines = Lines(file);
			if (!lines)
				continue;
			result.append(file);

			for (const QString& line : *lines)
			{
				if (!line.contains("include"))
					continue;
				QString inc = ParseInclude(line, file);
				if (!inc.isNull() && !result.contains(inc))
					queue.append(inc);
			}
		}

		return result;
	}
}
