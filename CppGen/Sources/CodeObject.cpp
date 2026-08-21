#include "CppGen.hpp"

namespace CppGen
{
CodeObject::CodeObject(int line)
{
	this->func = Function::currentParseFunction;
	this->line = line;
	CodeObject::totalObjects++;
}

String CodeObject::nameToCpp(String name)
{
	if (name == "app")
	{
		return "_app";
	}
	else if (name == "self")
	{
		return "this";
	}
	else if (name == "object_index")
	{
		return "subAssetId";
	}
	else if (name == "undefined")
	{
		return "VarType()";
	}
	else if (name == "block_size" || name == "char" || name == "double" || name == "export" || name == "far" || name == "float" || name == "inline" || name == "int" || name == "interface" || name == "near" || name == "NULL" || name == "null" || name == "pi" || name == "sample_rate" || name == "slots" || name == "small" || name == "template" || name == "typename" || name == "W" || name == "X" || name == "Y" || name == "Z")
	{
		return name + "_";
	}
	return name;
}

void CodeObject::resolve(ResolveScope*)
{}

}
