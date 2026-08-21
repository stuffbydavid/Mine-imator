#include "CppGen.hpp"

namespace CppGen
{
String Token::toCpp(Type type)
{
	switch (type)
	{
		case Type::LeftBrace: return "{";
		case Type::RightBrace: return "}";
		case Type::LeftPar: return "(";
		case Type::RightPar: return ")";
		case Type::LeftSquare: return "[";
		case Type::RightSquare: return "]";
		case Type::Separator: return ",";
		case Type::Terminator: return ";";
		case Type::Member: return ".";
		case Type::Assign: return "=";
		case Type::Equal: return "==";
		case Type::NotEqual: return "!=";
		case Type::Ternary: return "?";
		case Type::Colon: return ":";
		case Type::Inverse: return "!";
		case Type::Larger: return ">";
		case Type::LargerEq: return ">=";
		case Type::Less: return "<";
		case Type::LessEq: return "<=";
		case Type::And: return "&&";
		case Type::Or: return "||";
		case Type::Add: return "+";
		case Type::AddLong: return "+=";
		case Type::AddShort: return "++";
		case Type::Sub: return "-";
		case Type::SubLong: return "-=";
		case Type::SubShort: return "--";
		case Type::Mul: return "*";
		case Type::MulLong: return "*=";
		case Type::Div: return "/";
		case Type::DivLong: return "/=";
		case Type::DivInt: return "/";
		case Type::Modulus: return "%";
		case Type::ShiftLeft: return "<<";
		case Type::ShiftRight: return ">>";
		case Type::BitwiseOr: return "|";
		case Type::BitwiseAnd: return "&";
		case Type::HashTag: return "#";
		case Type::ArrayRef: return "@";
		default: return "";
	}
}

}
