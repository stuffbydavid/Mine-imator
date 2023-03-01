using System;
using System.Collections.Generic;

namespace CppGen
{
	// Expression base class
	public abstract class Expression : CodeObject
	{
		public Type type;
		public DataType ResolvedType, WrittenType = new DataType();
		public DataType.CppType ResolvedTypeCpp = DataType.CppType.Void; // If not void, can override the resolved C++ type
		public Variable AssignedTo = null;

		public enum Type
		{
			Accessor,
			Parenthesis,
			BinaryOperation,
			UnaryOperation,
			TernaryCondition,
			Array,
			Value,
			New
		}

		protected Expression(int line) : base(line) { }

		// Applies a derived type to the Expression and sub-expressions. Returns whether it will modify a variable in the project.
		public virtual bool ApplyType(ResolveScope scope, DataType type)
		{
			return false;
		}

		// Returns the C++ code of the expression.
		public virtual string ToCpp(ResolveScope scope)
		{
			return "";
		}

		// Wraps an expression in (x > 0) if needed, since C++ conditions are true for negative values.
		public virtual string ToConditionCpp(ResolveScope scope, bool parenthesis)
		{
			return ToCpp(scope);
		}

		// Returns a C++ ternary string from the given expressions.
		public static string ToTernaryCpp(ResolveScope scope, Expression expr1, Expression expr2, Expression expr3)
		{
			bool expr2TypeVarType = expr2.GetResolvedCppType() == DataType.CppType.VarType;
			bool expr3TypeVarType = expr3.GetResolvedCppType() == DataType.CppType.VarType;

			string cpp = expr1.ToConditionCpp(scope, true) + " ? ";

			if (expr3TypeVarType && !expr2TypeVarType) // Wrap expr2 in VarType() if expr3 is VarType
				cpp += "VarType(" + expr2.ToCpp(scope) + ")";
			else
				cpp += expr2.ToCpp(scope);

			cpp += " : ";

			if (expr2TypeVarType && !expr3TypeVarType) // Wrap expr3 in VarType() if expr2 is VarType
				cpp += "VarType(" + expr3.ToCpp(scope) + ")";
			else
				cpp += expr3.ToCpp(scope);

			return cpp;
		}

		// Returns a C++ array containing the given expressions as elements.
		public static string ToExpressionArrayCpp(ResolveScope scope, List<Expression> expressions)
		{
			if (expressions.Count == 0)
				return "{}";

			string cpp = "{ ";
			int p = 0;
			foreach (Expression expr in expressions)
				cpp += (p++ > 0 ? ", " : "") + expr.ToCpp(scope);
			cpp += " }";
			return cpp;
		}

		// Returns whether the expression is a integer value.
		public bool IsIntValue()
		{
			return (type == Type.Value && ((ExpressionValue)this).ValueType == Token.Type.Number && !((ExpressionValue)this).Value.Contains("."));
		}

		// Returns whether the expression is a real value.
		public bool IsRealValue()
		{
			return (type == Type.Value && ((ExpressionValue)this).ValueType == Token.Type.Number && ((ExpressionValue)this).Value.Contains("."));
		}

		// If the expression is an accessor without a chain, returns the name of it.
		public virtual string GetAccessorName()
		{
			return "";
		}

		// Returns the resolved type as a C++ type
		public DataType.CppType GetResolvedCppType()
		{
			return ResolvedTypeCpp != DataType.CppType.Void ? ResolvedTypeCpp : ResolvedType.cppType;
		}
	}

	// An expression in parenthesis
	public class ExpressionParenthesis : Expression
	{
		public Expression Expr;

		public ExpressionParenthesis(Expression expr, int line) : base(line)
		{
			Expr = expr;
			type = Type.Parenthesis;
		}

		public override void Resolve(ResolveScope scope)
		{
			Expr.Resolve(scope);
			ResolvedType = Expr.ResolvedType;
			ResolvedTypeCpp = Expr.ResolvedTypeCpp;
		}

		public override bool ApplyType(ResolveScope scope, DataType type)
		{
			bool changed = Expr.ApplyType(scope, type);
			ResolvedType = Expr.ResolvedType;
			ResolvedTypeCpp = Expr.ResolvedTypeCpp;
			return changed;
		}

		public override string ToCpp(ResolveScope scope)
		{
			return "(" + Expr.ToCpp(scope) + ")";
		}

		public override string ToConditionCpp(ResolveScope scope, bool parenthesis)
		{
			return "(" + Expr.ToConditionCpp(scope, false) + ")";
		}
	}

	// Operation taking a single expression
	public class UnaryOperation : Expression
	{
		public Token.Type Op;
		public Expression Expr;

		public UnaryOperation(Token.Type op, Expression expr, int line) : base(line)
		{
			Op = op;
			Expr = expr;
			type = Type.UnaryOperation;
		}

		public override void Resolve(ResolveScope scope)
		{
			Expr.Resolve(scope);

			if (Op == Token.Type.Sub) // -
			{
				Expr.ApplyType(scope, new DataType(DataType.Type.IntOrReal));
				ResolvedType = Expr.ResolvedType;
			}
			else // !
				ResolvedType = new DataType(DataType.Type.Bool);
		}

		public override bool ApplyType(ResolveScope scope, DataType type)
		{
			if (Op == Token.Type.Sub)
			{
				bool changed = Expr.ApplyType(scope, type);
				ResolvedType = Expr.ResolvedType;
				return changed;
			}
			else
				return false;
		}

		public override string ToCpp(ResolveScope scope)
		{
			if (Op == Token.Type.Sub) // -
				return "-" + Expr.ToCpp(scope);
			else // !
				return "!" + Expr.ToConditionCpp(scope, true);
		}
	}

	// Operation taking two expressions
	public class BinaryOperation : Expression
	{
		public Token.Type Op;
		public Expression Left;
		public Expression Right;

		public BinaryOperation(Token.Type op, Expression left, Expression right, int line) : base(line)
		{
			Op = op;
			Left = left;
			Right = right;
			type = Type.BinaryOperation;
		}

		public override void Resolve(ResolveScope scope)
		{
			Left.Resolve(scope);
			Right.Resolve(scope);

			if (Op == Token.Type.BitwiseAnd || Op == Token.Type.BitwiseOr ||
				Op == Token.Type.ShiftLeft || Op == Token.Type.ShiftRight) //  &, |, <<, >>, both expressions must be integer
			{
				Left.ApplyType(scope, new DataType(DataType.Type.Integer));
				Right.ApplyType(scope, new DataType(DataType.Type.Integer));
			}
			else if (Op == Token.Type.Div) // /, both expressions must be real
			{
				Left.ApplyType(scope, new DataType(DataType.Type.Real));
				Right.ApplyType(scope, new DataType(DataType.Type.Real));
			}

			if (Op == Token.Type.Or || Op == Token.Type.And || Op == Token.Type.Equal || Op == Token.Type.NotEqual) // ||, &&, ==, != returns bool
				ResolvedType = new DataType(DataType.Type.Bool);
			else if (Op == Token.Type.Add)
				ResolvedType = Left.ResolvedType;
			else
			{
				if (Op != Token.Type.Div)
					if (Left.GetResolvedCppType() == DataType.CppType.VarType ||
						Right.GetResolvedCppType() == DataType.CppType.VarType)
						ResolvedTypeCpp = DataType.CppType.VarType;

				ResolvedType = new DataType(DataType.Type.Real);
			}
		}

		public override bool ApplyType(ResolveScope scope, DataType type)
		{
			bool leftChanged = false, rightChanged = false;
			if (Op == Token.Type.Add) // +, both types are the same
			{
				leftChanged = Left.ApplyType(scope, type);
				rightChanged = Right.ApplyType(scope, type);
			}

			return (leftChanged || rightChanged);
		}

		public override string ToCpp(ResolveScope scope)
		{
			if (Op == Token.Type.Modulus) // mod
				return "mod(" + Left.ToCpp(scope) + ", " + Right.ToCpp(scope) + ")";

			if (Left.type == Type.Accessor && Right.type == Type.Accessor) // App pointer to app asset id
			{
				if (((Accessor)Left).Name == "object_index")
					((Accessor)Right).AppToId = false;
				if (((Accessor)Right).Name == "object_index")
					((Accessor)Left).AppToId = false;
			}

			string cpp = "";
			bool opNeedInts = (Op == Token.Type.ShiftLeft || Op == Token.Type.ShiftRight || Op == Token.Type.BitwiseAnd || Op == Token.Type.BitwiseOr);
			if (opNeedInts) // Cast left to int
				cpp += "(IntType)"; 
			else if (Op == Token.Type.Mul && Left.ResolvedType.cppType == DataType.CppType.BoolType) // Cast left bool to int when multiplying
				cpp += "(IntType)";
			else if (Op == Token.Type.Div && Left.ResolvedType.cppType != DataType.CppType.RealType) // Cast left to real for division
				cpp += "(RealType)";
			else if (Op == Token.Type.DivInt) // Cast result of division to int
				cpp += "(IntType)(";

			if (Op == Token.Type.And || Op == Token.Type.Or) // Convert to x > 0 for accessors
				cpp += Left.ToConditionCpp(scope, false);
			else
				cpp += Left.ToCpp(scope);

			cpp += " " + Token.ToCpp(Op) + " ";

			if (opNeedInts) // Cast left to int
				cpp += "(IntType)";
			else if (Op == Token.Type.Mul && Right.ResolvedType.cppType == DataType.CppType.BoolType) // Cast right bool to int when multiplying
				cpp += "(IntType)";

			if (Op == Token.Type.And || Op == Token.Type.Or) // Convert to x > 0 for accessors
				cpp += Right.ToConditionCpp(scope, false);
			else
				cpp += Right.ToCpp(scope);

			if (Op == Token.Type.DivInt) // Cast result of division to int
				cpp += ")";

			return cpp;
		}
	}

	// Ternary expression
	public class TernaryCondition : Expression
	{
		public Expression Expr1;
		public Expression Expr2;
		public Expression Expr3;

		public TernaryCondition(Expression expr1, Expression expr2, Expression expr3, int line) : base(line)
		{
			Expr1 = expr1;
			Expr2 = expr2;
			Expr3 = expr3;
			type = Type.TernaryCondition;
		}

		public override void Resolve(ResolveScope scope)
		{
			Expr1.Resolve(scope);
			Expr2.Resolve(scope);
			Expr3.Resolve(scope);

			Expr1.ApplyType(scope, new DataType(DataType.Type.IntOrReal));

			// Both types should be the same
			Expr3.ApplyType(scope, Expr2.ResolvedType);
			Expr2.ApplyType(scope, Expr3.ResolvedType);

			ResolvedType = new DataType(Expr3.ResolvedType);
			ResolvedType.Assign(Expr2.ResolvedType, Func, Line);
		}

		public override bool ApplyType(ResolveScope scope, DataType type)
		{
			bool expr2Changed = Expr2.ApplyType(scope, type);
			bool expr3Changed = Expr3.ApplyType(scope, type);

			return (expr2Changed || expr3Changed);
		}

		public override string ToCpp(ResolveScope scope)
		{
			return ToTernaryCpp(scope, Expr1, Expr2, Expr3);
		}
	}

	// Array
	public class ExpressionArray : Expression
	{
		public List<Expression> Expressions;

		public ExpressionArray(List<Expression> expressions, int line) : base(line)
		{
			Expressions = expressions;
			type = Type.Array;
		}

		public override void Resolve(ResolveScope scope)
		{
			ResolvedType = new DataType(DataType.Type.Array, new DataType());
			foreach (Expression expr in Expressions)
			{
				expr.Resolve(scope);
				ResolvedType.Assign(new DataType(DataType.Type.Array, expr.ResolvedType), Func, Line);
			}
		}

		public override string ToCpp(ResolveScope scope)
		{
			return "ArrType::From(" + ToExpressionArrayCpp(scope, Expressions) + ")";
		}
	}

	// Expression value (string or number)
	public class ExpressionValue : Expression
	{
		public Token.Type ValueType;
		public string Value;

		public ExpressionValue(Token.Type valueType, string value, int line) : base(line)
		{
			ValueType = valueType;
			Value = value;
			type = Type.Value;
		}

		public override void Resolve(ResolveScope scope)
		{
			if (ValueType == Token.Type.Number)
			{
				if (Value.Contains("."))
					ResolvedType = new DataType(DataType.Type.Real);
				else
					ResolvedType = new DataType(DataType.Type.IntOrReal);
			}
			else
				ResolvedType = new DataType(DataType.Type.String);
		}

		public override bool ApplyType(ResolveScope scope, DataType type)
		{
			return ResolvedType.Assign(type, Func, Line);
		}

		public override string ToCpp(ResolveScope scope)
		{
			if (ValueType == Token.Type.String) // String
				return "/*\"" + Value + "\"*/ STR(" + Program.Strings.IndexOf(Value) + ")";
			else if (ResolvedType == null || ResolvedType.GetAssignments(DataType.Type.Real).Count == 0) // Integer
				return "IntType(" + Value + ")";
			else if (!Value.Contains(".")) // Convert to Real
				return Value + ".0";
			else // Already real
				return Value;
		}
	}

	// New expression
	public class NewExpression : Expression
	{
		public Accessor Acc;

		public NewExpression(Accessor accessor, int line) : base(line)
		{
			Acc = accessor;
			type = Type.New;
		}

		public override void Resolve(ResolveScope scope)
		{
			ResolveScope newScope = scope.NextStatement(true);
			Acc.Resolve(newScope);
			ResolvedType = Acc.ResolvedType;
		}

		public override string ToCpp(ResolveScope scope)
		{
			ResolveScope newScope = scope.NextStatement(true);
			return "(new " + Acc.ToCpp(newScope) + ")->id";
		}
	}
}
