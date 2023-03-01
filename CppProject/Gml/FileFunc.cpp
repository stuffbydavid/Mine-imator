#include "Generated/Scripts.hpp"

#include "Asset/TextFile.hpp"
#include "AppHandler.hpp"

#include <QDirIterator>
#include <QFileDialog>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonArray>

namespace CppProject
{
	QDirIterator* fileFindIt = nullptr;

	BoolType file_delete(StringType file)
	{
		return lib_file_delete(file);
	}

	BoolType file_exists(StringType file)
	{
		return lib_file_exists(file);
	}

	void file_find_close()
	{
		deleteAndReset(fileFindIt);
	}

	StringType file_find_first(StringType dir, IntType attr)
	{
		deleteAndReset(fileFindIt);

		int wildCardIndex = dir.IndexOf("*"); // Wildcard not supported (unused in code)
		if (wildCardIndex >= 0)
			dir = dir.Left(wildCardIndex);

		fileFindIt = new QDirIterator(dir, QDir::Files | QDir::NoDotAndDotDot);
		if (fileFindIt->hasNext())
			return filename_name(fileFindIt->next());

		return "";
	}

	StringType file_find_next()
	{
		if (fileFindIt && fileFindIt->hasNext())
			return filename_name(fileFindIt->next());
		return "";
	}

	BoolType file_rename(StringType src, StringType dst)
	{
		return lib_file_rename(src, dst);
	}

	void file_text_close(IntType id)
	{
		if (TextFile* tFile = FindTextFile(id))
			delete tFile;
	}

	BoolType file_text_eof(IntType id)
	{
		if (TextFile* tFile = FindTextFile(id))
			return tFile->IsEof();
		return false;
	}

	IntType file_text_open_append(StringType file)
	{
		QFile* qFile = new QFile(file);
		if (qFile->open(QFile::Append | QFile::Text))
			return (new TextFile(qFile, false))->id;
		else
			delete qFile;
		return -1;
	}

	IntType file_text_open_read(StringType file)
	{
		QFile* qFile = new QFile(file);
		if (qFile->open(QFile::ReadOnly | QFile::Text))
			return (new TextFile(qFile, true))->id;
		else
			delete qFile;
		return -1;
	}

	IntType file_text_open_write(StringType file)
	{
		QFile* qFile = new QFile(file);
		AddPerms(*qFile);
		if (qFile->open(QFile::WriteOnly | QFile::Text))
			return (new TextFile(qFile, false))->id;
		else
		{
			WARNING("Could not open file " + file.QStr() + ": " + qFile->errorString());
			delete qFile;
		}
		return -1;
	}

	StringType file_text_read_string(IntType id)
	{
		if (TextFile* tFile = FindTextFile(id))
			return tFile->ReadWord();
		return "";
	}

	StringType file_text_readln(IntType id)
	{
		if (TextFile* tFile = FindTextFile(id))
			return tFile->ReadLine();
		return "";
	}

	IntType file_text_write_string(IntType id, StringType str)
	{
		if (TextFile* tFile = FindTextFile(id))
			if (tFile->stream)
				*tFile->stream << str;
		return 0;
	}

	IntType file_text_writeln(IntType id)
	{
		if (TextFile* tFile = FindTextFile(id))
			if (tFile->stream)
				*tFile->stream << "\n";
		return 0;
	}

	StringType filename_change_ext(StringType file, StringType newext)
	{
		QFileInfo info(file);
		return info.path() + "/" + info.completeBaseName() + newext;
	}

	StringType filename_dir(StringType file)
	{
		return QFileInfo(file).path();
	}

	StringType filename_ext(StringType file)
	{
		QString suffix = QFileInfo(file).suffix();
		if (suffix.isEmpty())
			return "";
		return "." + suffix;
	}

	StringType filename_name(StringType file)
	{
		return QFileInfo(file).fileName();
	}

	StringType filename_path(StringType file)
	{
		return QFileInfo(file).path() + "/";
	}

	QStringList GetFilenameFilterList(StringType str)
	{
		if (str.IsEmpty())
			return QStringList();

		QStringList list;
		QStringList strSplit = str.Split('|');
		for (IntType i = 0; i < strSplit.size(); i += 2)
		{
			QString name = strSplit.at(i);
			QString filter = strSplit.at(i + 1);
			filter.replace(";", " ");

			IntType parIndex = name.indexOf("(");
			if (parIndex >= 0)
				name = name.left(parIndex - 1);

			list.append(name + " (" + filter + ")");
		}
		return list;
	}

	StringType get_open_filename_ext(StringType filter, StringType file, StringType dir, StringType caption)
	{
		QFileDialog fd;
		fd.setModal(true);
		fd.setAcceptMode(QFileDialog::AcceptOpen);
		fd.setFileMode(QFileDialog::ExistingFile);
		fd.setNameFilters(GetFilenameFilterList(filter));
		if (file != "")
		{
			if (!file.Contains("/") && !dir.IsEmpty())
				file = dir + "/" + file;
			fd.selectFile(file);
		}
		else if (!dir.IsEmpty())
			fd.setDirectory(dir);
		fd.setWindowTitle(caption);
		if (!App->ExecDialog(&fd))
			return "";

		QStringList files = fd.selectedFiles();
		if (files.size() > 0)
			return files[0];
		return "";
	}

	StringType get_save_filename_ext(StringType filter, StringType file, StringType dir, StringType caption)
	{
		QFileDialog fd;
		fd.setModal(true);
		fd.setAcceptMode(QFileDialog::AcceptSave);
		fd.setFileMode(QFileDialog::AnyFile);
		fd.setNameFilters(GetFilenameFilterList(filter));
		if (file != "")
		{
			if (!file.Contains("/") && !dir.IsEmpty())
				file = dir + "/" + file;
			fd.selectFile(file);
		}
		else if (!dir.IsEmpty())
			fd.setDirectory(dir);
		fd.setWindowTitle(caption);
		if (!App->ExecDialog(&fd))
			return "";

		QStringList files = fd.selectedFiles();
		if (files.size() > 0)
			return files[0];
		return "";
	}

	IntType json_load_from_string(StringType json, IntType typeMapId = 0)
	{
		if (json.IsEmpty() || (!json.StartsWith("{") && !json.StartsWith("[")))
			return -1;

		IntHashMap* typeMap = FindSubAssetOpt(IntHashMap, Map, typeMapId);
		QJsonParseError jsonError;
		QJsonDocument loadDoc = QJsonDocument::fromJson(json.ToUtf8(), &jsonError);
		if (jsonError.error)
		{
			global::json_error = jsonError.errorString() + " on line " + NumStr(json.Left(jsonError.offset).Count("\n"));
			DEBUG("JSON error: " + global::json_error);
			return -1;
		}

		function<VarType(const QJsonValue&, e_json_type& outType)> loadValue;
		function<IntType(const QJsonArray&)> loadArray;
		function<IntType(const QJsonObject&)> loadObject;

		loadValue = [](const QJsonValue& val, e_json_type& outType)
		{
			if (val.isBool())
			{
				outType = e_json_type_BOOL;
				return VarType(val.toBool());
			}
			else if (val.isDouble())
			{
				outType = e_json_type_NUMBER;
				return VarType((RealType)val.toDouble());
			}
			else if (val.isString())
			{
				outType = e_json_type_STRING;
				return VarType(val.toString());
			}
			else if (val.isNull())
			{
				outType = e_json_type_NULL_;
				return VarType(null_);
			}

			WARNING("Unknown QJsonValue");
			return VarType();
		};

		loadArray = [&loadValue, &loadArray, &loadObject](const QJsonArray& arr)
		{
			List* list = new List;
			list->vec.reserve(arr.size());
			for (const QJsonValue& val : arr)
			{
				e_json_type jsonType;
				if (val.isArray())
					list->vec.append({ loadArray(val.toArray()), ds_type_list });
				else if (val.isObject())
					list->vec.append({ loadObject(val.toObject()), ds_type_map });
				else
					list->vec.append({ loadValue(val, jsonType), 0 });
			}
			return list->id;
		};

		loadObject = [typeMap, &loadValue, &loadArray, &loadObject](const QJsonObject& obj)
		{
			StringHashMap* map = new StringHashMap;
			StringHashMap* mapTypes = nullptr;

			// Store types
			if (typeMap)
			{
				mapTypes = new StringHashMap;
				typeMap->hash[map->id] = { mapTypes->id, ds_type_map };
			}

			for (StringType key : obj.keys())
			{
				const QJsonValue& val = obj.value(key);
				e_json_type jsonType;

				if (val.isArray())
				{
					jsonType = e_json_type_ARRAY;
					map->hash[key] = { loadArray(val.toArray()), ds_type_list };
				}
				else if (val.isObject())
				{
					jsonType = e_json_type_OBJECT;
					map->hash[key] = { loadObject(val.toObject()), ds_type_map };
				}
				else
				{
					VarType var = loadValue(val, jsonType);
					map->hash[key] = { var, 0 };
				}

				if (mapTypes)
					mapTypes->hash[key].value = jsonType;
			}

			return map->id;
		};

		return loadObject(loadDoc.object());
	}

	IntType json_decode(StringType json)
	{
		return json_load_from_string(json);
	}

	IntType json_load(VarArgs args)
	{
		QFile file(args[0].ToStr());
		if (!file.open(QFile::ReadOnly))
			return -1;
		
		IntType typeMap = 0;
		if (args.Size() > 1)
			typeMap = args[1];
		return json_load_from_string(file.readAll(), typeMap);
	}

	StringType json_string_encode(StringType arg)
	{
		QString str = arg.QStr();
		IntType newLen = 0;
		for (QChar c : str)
		{
			if (c == '\n' || c == '\t' || c == '"' || c == '\\')
				newLen += 2;
			else if (c.unicode() > 127)
				newLen += 5;
			else
				newLen++;
		}

		if (str.length() == newLen)
			return arg;

		QString nstr;
		nstr.reserve(newLen);
		for (QChar c : str)
		{
			if (c == '\n')
				nstr += "\\n";
			else if (c == '\t')
				nstr += "\\t";
			else if (c == '"')
				nstr += "\\\"";
			else if (c == '\\')
				nstr += "\\\\";
			else if (c.unicode() > 127)
				nstr += "\\u" + QString("%1").arg(c.unicode(), 4, 16, QLatin1Char('0')).toLower();
			else
				nstr += c;
		}

		return nstr;
	}
}
