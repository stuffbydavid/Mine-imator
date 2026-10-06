#pragma once
#include "SpCommon.hpp"

namespace ShaderPacks
{
	// Value of a custom uniform expression (bool, int, float or float vector).
	struct ExprValue
	{
		enum Type { BOOL, INT, FLOAT, VEC2, VEC3, VEC4, MAT2, MAT3, MAT4 };

		Type type = FLOAT;
		float v[16] = { 0.f }; // Matrices are stored column-major

		static ExprValue Bool(bool b) { ExprValue r; r.type = BOOL; r.v[0] = b ? 1.f : 0.f; return r; }
		static ExprValue Int(int i) { ExprValue r; r.type = INT; r.v[0] = (float)i; return r; }
		static ExprValue Float(float f) { ExprValue r; r.type = FLOAT; r.v[0] = f; return r; }
		static ExprValue Vec(int n, const float* c);
		static ExprValue Mat(int n, const float* c);

		// Number of columns/rows of a matrix type, 0 otherwise.
		int MatrixSize() const { return type == MAT2 ? 2 : type == MAT3 ? 3 : type == MAT4 ? 4 : 0; }

		int Components() const { return type == VEC2 ? 2 : type == VEC3 ? 3 : type == VEC4 ? 4 : 1; }
		float AsFloat() const { return v[0]; }
		bool AsBool() const { return v[0] != 0.f; }

		// Converts the value to the given type.
		ExprValue Cast(Type t) const;

		static Type TypeFromName(const QString& name, bool* ok = nullptr);
	};

	// State shared by expression evaluations, such as smoothing accumulators.
	struct ExprContext
	{
		// Resolves a variable or built-in uniform by name.
		std::function<bool(const QString& name, ExprValue& out)> lookup;

		// Seconds since the last frame.
		float frameTime = 0.f;

		// smooth() state per call site
		struct Smooth
		{
			bool init = false;
			float acc = 0.f;
		};
		QHash<QString, Smooth> smooth;
	};

	// A parsed custom uniform/variable expression from shaders.properties.
	class Expression
	{
	public:
		~Expression();

		// Parses an expression, returns nullptr on error.
		static std::shared_ptr<Expression> Parse(const QString& text, QString* error = nullptr);

		// Evaluates the expression.
		ExprValue Evaluate(ExprContext& ctx) const;

		// Names referenced by the expression.
		QSet<QString> References() const;

		struct Node;

	private:
		Node* root = nullptr;
		QString text;
	};

	// Evaluates a boolean expression of option names (used by program.<name>.enabled), like Iris' BooleanParser.
	bool EvaluateBooleanOptionExpression(const QString& expr, const std::function<bool(const QString&)>& lookup);
}
