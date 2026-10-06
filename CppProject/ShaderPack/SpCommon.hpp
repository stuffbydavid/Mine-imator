#pragma once
// Shared definitions for the native shaderpack (OptiFine/Iris format) engine.
// The engine only depends on Qt and OpenGL so it can also be built by the
// standalone test harness in Tools/ShaderPackTest.

#include <QHash>
#include <QMap>
#include <QSet>
#include <QString>
#include <QStringList>
#include <QVector>

#include <functional>
#include <memory>

namespace ShaderPacks
{
	enum class LogLevel { Info, Warning, Error };

	// Logging hook, the host application can redirect messages to its own log.
	extern std::function<void(LogLevel, const QString&)> logHandler;

	void LogInfo(const QString& msg);
	void LogWarning(const QString& msg);
	void LogError(const QString& msg);

	// An ordered key/value list, used for properties files where the order of entries matters.
	struct OrderedProperties
	{
		QStringList keys;
		QHash<QString, QString> values;

		void Set(const QString& key, const QString& value)
		{
			if (!values.contains(key))
				keys.append(key);
			values[key] = value;
		}

		bool Has(const QString& key) const { return values.contains(key); }
		QString Get(const QString& key, const QString& def = QString()) const { return values.value(key, def); }
	};

	// Parses a .properties file (Java format) into ordered key/value pairs.
	// Supports "key=value", "key:value", "key value", backslash line continuations and # or ! comments.
	OrderedProperties ParseProperties(const QString& text);

	// Normalizes a path inside a shaderpack, resolving "." and ".." and removing duplicate slashes.
	// The result never begins with a slash, the empty string refers to the shaders root.
	QString NormalizePackPath(const QString& path);

	// Returns the directory part of a normalized pack path ("" for files in the root).
	QString PackPathDir(const QString& path);

	// Parses a "true"/"false"/"on"/"off"/"1"/"0" string, returns def on failure.
	bool ParseBool(const QString& value, bool def);
}
