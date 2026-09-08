#include "CppGen.hpp"

namespace CppGen
{
ExternalFunction::ExternalFunction(StringId name, DataType* returnType, List<DataType*> argTypes)
{
	this->name = name;
	this->returnType = returnType;
	this->argTypes = argTypes;
}

void ExternalFunction::writeCppHeader()
{
	CodeWriter::write(this->returnType->toCpp() + " " + CodeObject::nameToCpp(this->name));

	CodeWriter::write("(");
	int a = 0;
	for (DataType* type : this->argTypes)
	{
		if (a++ > 0)
			CodeWriter::write(", ");
		CodeWriter::write(type->toCpp());
	}
	CodeWriter::writeLine(");");
}

}
