#pragma once
#include "SpCommon.hpp"

namespace ShaderPacks
{
	// C-style preprocessor used for GLSL sources and .properties files of shaderpacks.
	// Evaluates conditionals, fully expands object-like and function-like macros and keeps
	// comments so that comment directives (DRAWBUFFERS, RENDERTARGETS, formats) survive.
	class Preprocessor
	{
	public:
		Preprocessor();
		~Preprocessor();

		// Defines a macro, the value may be empty. Function-like macros can be defined with
		// a name in the form "NAME(a,b)".
		void Define(const QString& name, const QString& value = QString());

		// Removes a macro definition.
		void Undefine(const QString& name);

		// Returns whether a macro is defined.
		bool IsDefined(const QString& name) const;

		// Result of processing a source.
		struct Result
		{
			QString source;			// Processed source without #version and #extension directives
			QString version;		// The #version directive line (empty if none found)
			QStringList extensions; // Active #extension directive lines, in order
			QStringList errors;		// Messages from active #error directives or parse problems
		};

		// Processes GLSL source code. Macros defined by the source persist in this preprocessor.
		Result ProcessGlsl(const QString& source);

		// Processes a .properties file, only lines starting with a known directive are treated
		// as directives, other lines starting with # are comments. Macros are expanded in values.
		QString ProcessProperties(const QString& source);

		// Evaluates a #if style condition using the current macro definitions.
		bool EvaluateCondition(const QString& expression, bool* ok = nullptr);

	private:
		struct Impl;
		std::unique_ptr<Impl> impl;
	};
}
