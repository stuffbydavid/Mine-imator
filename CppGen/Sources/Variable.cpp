#include "CppGen.hpp"

namespace CppGen
{
Variable::Variable(String scope, String name, const DataType& type, int line, const Statement::Location& location)
{
	this->scope = scope;
	this->name = name;
	if (Program::varTypeOverride.containsKey(this->name))
		this->type = Program::varTypeOverride[this->name];
	else
		this->typeStorage.reset(type);
	this->line = line;
	this->location = location;

	if (this->scope != "")
	{
		Variable::totalVariables++;
		Variable::variantVariables += this->type->isCppVarType() ? 1 : 0;
	}
}

bool Variable::assignType(const DataType& inputType, Function* sourceFunc, int sourceLine)
{
	if (Program::varTypeOverride.containsKey(this->name))
		return false;

	if (this->scope != "")
		Variable::variantVariables -= this->type->isCppVarType() ? 1 : 0;

	bool changed = this->type->assign(inputType, sourceFunc, sourceLine);

	if (this->scope != "")
		Variable::variantVariables += this->type->isCppVarType() ? 1 : 0;
	return changed;
}

void Variable::markReference()
{
	if (this->line != 0 || !Program::functions.containsKey(this->scope))
		return;
	if (Program::functions[this->scope]->varArgs)
		Program::addSyntaxError("@ operator not supported inside scripts using argument[] in " + this->scope + ":" + this->line);

	this->type->assign(DataType(DataType::Type::Variant), nullptr, 0); // Convert to VarType to allow .Arr()/.Ref(i)
	this->isReference = true;

	for (Declaration* decl : Program::functions[this->scope]->args->declarations)
	{
		if (decl->name == this->name)
		{
			if (decl->expr != nullptr)
				Program::addSyntaxError("@ operator only supported on arguments with no default value " + this->scope + ":" + this->line);

			decl->isReference = true;
			return;
		}
	}
}

}
