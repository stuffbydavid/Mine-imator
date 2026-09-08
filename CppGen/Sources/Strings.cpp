#include "CppGen.hpp"
#include "Strings.hpp"

namespace CppGen
{
std::unordered_map<int, std::unique_ptr<String>> idToString;
std::unordered_map<String, int> stringToId;
int nextId = static_cast<int>(Strings::NextId);

void StringId::set(const String& value)
{
	if (value.empty())
	{
		clear();
		return;
	}
	const auto found = stringToId.find(value);
	if (found != stringToId.end())
	{
		id_ = found->second;
		return;
	}

	id_ = nextId++;
	auto stored = std::make_unique<String>(value);
	stringToId.emplace(*stored, id_);
	idToString.emplace(id_, std::move(stored));
}

StringId::operator const String& () const
{
	return *idToString.at(id_);
}

void addString(Strings id, const char* value)
{
	auto stored = std::make_unique<String>(value);
	stringToId.emplace(*stored, id);
	idToString.emplace(id, std::move(stored));
}

void StringId::initialize()
{
	addString(Strings::Empty, "");
#define ADD(name) addString(Strings::str_##name, #name);
	PREDEFINED_STRINGS
#undef ADD

	nextId = static_cast<int>(Strings::NextId);
}

List<String> StringId::allValues()
{
	List<String> values;
	values.reserve(nextId);
	for (int id = 0; id < nextId; id++)
		values.add(*idToString.at(id));
	return values;
}

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
