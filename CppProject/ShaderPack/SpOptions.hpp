#pragma once
#include "SpCommon.hpp"

namespace ShaderPacks
{
	class IncludeResolver;

	// A user-configurable option discovered in the shaderpack source code.
	struct Option
	{
		enum Kind { BOOLEAN, STRING };
		enum Source { DEFINE, CONST };

		QString name;
		Kind kind = BOOLEAN;
		Source source = DEFINE;
		QString comment;
		QString defaultValue; // "true"/"false" for booleans
		QStringList allowedValues; // For string options
	};

	// Discovers options in shaderpack sources and applies user values to them.
	class Options
	{
	public:
		// Scans the given files for options.
		void Discover(const IncludeResolver& includes, const QStringList& files);

		// Returns whether an option exists.
		bool Has(const QString& name) const { return options.contains(name); }

		// Returns the current value of an option ("true"/"false" for booleans).
		QString Value(const QString& name) const;

		// Returns the current value of a boolean option.
		bool BoolValue(const QString& name) const;

		// Sets the value of an option, returns whether the option exists and the value is valid.
		bool SetValue(const QString& name, const QString& value);

		// Resets all options to their defaults.
		void ResetAll() { values.clear(); }

		// Returns the edited version of a source line, applying current option values.
		QString ApplyToLine(const QString& file, int line, const QString& text) const;

		// Loads/saves values in the OptiFine "key=value" settings format.
		void LoadSettings(const QString& text);
		QString SaveSettings() const;

		// Applies a profile defined in shaders.properties (profile.NAME=...), returns programs it disables.
		QStringList ApplyProfile(const QString& profile, const QHash<QString, QString>& profiles);

		// All discovered options by name, and in discovery order.
		QHash<QString, Option> options;
		QStringList order;

		// Values changed from the default by the user.
		QHash<QString, QString> values;

	private:
		struct LineKey
		{
			QString file;
			int line;
			bool operator==(const LineKey& o) const { return line == o.line && file == o.file; }
		};
		friend uint qHash(const LineKey& k, uint seed) { return qHash(k.file, seed) ^ (uint)k.line; }

		QHash<LineKey, QString> lineOptions; // Location -> option name
	};

	// Localized names from the lang/ folder of a pack.
	struct LanguageMap
	{
		QHash<QString, QString> entries;

		void Load(const QString& text);
		QString Get(const QString& key, const QString& def = QString()) const { return entries.value(key, def); }
	};
}
