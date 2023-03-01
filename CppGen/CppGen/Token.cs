namespace CppGen
{
	public class Token
	{
		public Type type;
		public string Value;

		public int FileOffset;
		public int Line;
		public int LineOffset;
		public int Length;

		public enum Type
		{
			Unknown,
			ID, // ID to a function, variable, resource or keyword
			Number, // Number value
			String, // "String value"
			LeftBrace, // {
			RightBrace, // }
			LeftPar, // (
			RightPar, // )
			LeftSquare, // [
			RightSquare, // ]
			Separator, // ,
			Terminator, // ;
			Member, // .
			Assign, // =
			Equal, // ==
			NotEqual, // !=
			Ternary, // ?
			Colon, // :
			Inverse, // !
			Larger, // >
			LargerEq, // >=
			Less, // <
			LessEq, // <=
			And, // &&
			Or, // ||
			Add, // +
			AddLong, // +=
			AddShort, // ++
			Sub, // -
			SubLong, // -=
			SubShort, // --
			Mul, // *
			MulLong, // *=
			Div, // /
			DivLong, // /=
			DivInt, // div
			Modulus, // % or mod
			ShiftLeft, // <<
			ShiftRight, // >>
			BitwiseOr, // |
			BitwiseAnd, // &
			HashTag, // #
			ArrayRef, // @
			CppOnly,
			Error
		}

		// Gets the C++ string of the token.
		static public string ToCpp(Type type)
		{
			switch (type)
			{
				case Type.LeftBrace: return "{";
				case Type.RightBrace: return "}";
				case Type.LeftPar: return "(";
				case Type.RightPar: return ")";
				case Type.LeftSquare: return "[";
				case Type.RightSquare: return "]";
				case Type.Separator: return ",";
				case Type.Terminator: return ";";
				case Type.Member: return ".";
				case Type.Assign: return "=";
				case Type.Equal: return "==";
				case Type.NotEqual: return "!=";
				case Type.Ternary: return "?";
				case Type.Colon: return ":";
				case Type.Inverse: return "!";
				case Type.Larger: return ">";
				case Type.LargerEq: return ">=";
				case Type.Less: return "<";
				case Type.LessEq: return "<=";
				case Type.And: return "&&";
				case Type.Or: return "||";
				case Type.Add: return "+";
				case Type.AddLong: return "+=";
				case Type.AddShort: return "++";
				case Type.Sub: return "-";
				case Type.SubLong: return "-=";
				case Type.SubShort: return "--";
				case Type.Mul: return "*";
				case Type.MulLong: return "*=";
				case Type.Div: return "/";
				case Type.DivLong: return "/=";
				case Type.DivInt: return "/";
				case Type.Modulus: return "%";
				case Type.ShiftLeft: return "<<";
				case Type.ShiftRight: return ">>";
				case Type.BitwiseOr: return "|";
				case Type.BitwiseAnd: return "&";
				case Type.HashTag: return "#";
				case Type.ArrayRef: return "@";
			}
			return "";
		}
	}
}
