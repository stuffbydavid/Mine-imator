#pragma once
#include "SpCommon.hpp"

#include <QByteArray>

namespace ShaderPacks
{
	// Read-only access to the files of a shaderpack stored in a folder or a .zip archive.
	// Paths are relative to the "shaders" folder of the pack.
	class PackFiles
	{
	public:
		virtual ~PackFiles() {}

		// Opens a shaderpack folder or zip file, returns nullptr if it isn't a valid shaderpack.
		static std::unique_ptr<PackFiles> Open(const QString& path, QString* error = nullptr);

		// Returns whether a file exists in the pack.
		virtual bool Exists(const QString& path) const = 0;

		// Reads a file from the pack, returns whether successful.
		virtual bool Read(const QString& path, QByteArray& data) const = 0;

		// Returns all file paths in the pack (normalized, relative to the shaders folder).
		virtual QStringList Files() const = 0;

		// Reads a file as text, returns a null string if missing.
		QString ReadText(const QString& path) const;

		// Returns whether a directory exists in the pack.
		bool DirExists(const QString& dir) const;

		// Name of the pack (file or folder name).
		QString name;

		// Location on disk.
		QString location;
	};

	// Reads GLSL source files and flattens #include directives.
	class IncludeResolver
	{
	public:
		IncludeResolver(const PackFiles& files) : files(files) {}

		// Returns the lines of a file, with an optional per-file line transformation (used to apply options).
		using LineTransform = std::function<QString(const QString& file, int line, const QString& text)>;

		// Returns the flattened source of a file, or a null string if the file doesn't exist.
		QString Flatten(const QString& path, const LineTransform& transform = nullptr, QStringList* errors = nullptr) const;

		// Returns the raw lines of a file (cached).
		const QStringList* Lines(const QString& path) const;

		// Returns all files reachable through #include from the given start files.
		QStringList Reachable(const QStringList& starts) const;

		// Parses an #include line, returns the resolved path or a null string.
		static QString ParseInclude(const QString& line, const QString& currentFile);

	private:
		void FlattenInto(const QString& path, QString& out, QStringList& stack, const LineTransform& transform, QStringList* errors) const;

		const PackFiles& files;
		mutable QHash<QString, QStringList> cache;
	};
}
