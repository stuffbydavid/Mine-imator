#include "CppGen.hpp"

namespace CppGen
{
CodeObject::CodeObject(int line)
{
	this->func = Function::currentParseFunction;
	this->line = line;
	CodeObject::totalObjects++;
}

String CodeObject::nameToCpp(StringId name)
{
	switch (name.id())
	{
		case STR(app): return "_app";
		case STR(self): return "this";
		case STR(object_index): return "subAssetId";
		case STR(undefined): return "VarType()";
		case STR(block_size):
		case STR(char):
		case STR(double):
		case STR(export):
		case STR(far):
		case STR(float):
		case STR(inline):
		case STR(int):
		case STR(interface):
		case STR(near):
		case STR(NULL):
		case STR(null):
		case STR(pi):
		case STR(sample_rate):
		case STR(slots):
		case STR(small):
		case STR(template):
		case STR(typename):
		case STR(W):
		case STR(X):
		case STR(Y):
		case STR(Z):
			return String(name) + "_";
		default:
			return String(name);
	}
}

void CodeObject::resolve(ResolveScope*)
{}

}
