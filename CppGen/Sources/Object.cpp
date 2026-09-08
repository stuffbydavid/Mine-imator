#include "CppGen.hpp"

namespace CppGen
{
Object::Object(StringId name, bool isStruct)
{
	this->name = name;
	this->isStruct = isStruct;
}

Object::Object(String dir)
{
	DirectoryInfo dirInfo = DirectoryInfo(dir);
	this->name = dirInfo.name;

	// Parse selected events and their script
	List<String> objectEventFiles = Directory::getFiles(dir, "*.gml");
	for (String eventFile : objectEventFiles)
	{
		FileInfo eventFileInfo = FileInfo(eventFile);
		String gml = File::readAllText(eventFile);
		String funcName = gml.replace("()", "").replace(";", "").trim();

		if (!Program::functions.containsKey(funcName))
			continue;
		Function* func = Program::functions[funcName];

		if (eventFileInfo.name == "Create_0.gml")
			this->createFunction = func;
		else if (eventFileInfo.name == "Destroy_0.gml")
			this->destroyFunction = func;
		else if (dirInfo.name == "app")
		{
			if (eventFileInfo.name == "Draw_0.gml")
				Program::appDrawFunction = func;
			else if (eventFileInfo.name == "Other_3.gml")
				Program::appGameEndFunction = func;
			else if (eventFileInfo.name == "Other_62.gml")
				Program::appHttpFunction = func;
			else if (eventFileInfo.name == "Step_0.gml")
				Program::appStepFunction = func;
			else
				Console::writeLine("WARNING: Unsupported event {0} in {1}, it will be ignored.", eventFileInfo.name, "app");
		}
		else
			Console::writeLine("WARNING: Unsupported event {0} in {1}, it will be ignored." + eventFileInfo.name, dirInfo.name);
	}
}

void Object::setConstructor(Function* func)
{
	this->constructor = func;
	func->structObject = this;
	func->isConstructor = true;
	func->cppLinesBegin.add("InitMembers();");
}

void Object::setDestructor(Function* func)
{
	this->destructor = func;
	func->structObject = this;
	func->isDestructor = true;
}

void Object::writeCppHeader()
{
	CodeWriter::writeLine("struct " + String(this->name) + ": Object");
	CodeWriter::writeLine("{", 1);

	// Variables
	for (Variable* var : this->instanceVars.values)
		if (var->name != STR(id) && var->name != STR(subAssetId))
			CodeWriter::writeLine(var->type->toCpp() + " " + CodeObject::nameToCpp(var->name) + ";");

	if (this->constructor != nullptr || this->destructor != nullptr || this->instanceFunctions.values.size() > 0)
		CodeWriter::writeLine();

	// Constructor header
	if (this->constructor != nullptr)
	{
		CodeWriter::write(String(this->name) + "(");
		if (this->constructor->args != nullptr)
			this->constructor->args->writeCpp(ResolveScope(STR(global)), DeclarationList::WriteFormat::ArgsHeader);
		CodeWriter::writeLine(");");
	}

	// Destructor header
	if (this->destructor != nullptr)
		CodeWriter::writeLine("~" + String(this->name) + "();");

	CodeWriter::writeLine("void InitMembers() override;");

	// Instance functions
	for (Function* func : this->instanceFunctions.values)
		func->writeCppHeader();

	CodeWriter::writeLine("};", -1);
}

bool Object::writeCppImplementation()
{
	if (this->implWritten)
		return false;
	this->implWritten = true;

	// Constructor
	if (this->constructor != nullptr)
		this->constructor->writeCppImplementation();

	// Destructor
	if (this->destructor != nullptr)
		this->destructor->writeCppImplementation();

	for (Function* func : this->instanceFunctions.values)
		func->writeCppImplementation();
	return true;
}

void Object::writeInitMembers()
{
	CodeWriter::writeLine("void " + String(this->name) + "::InitMembers()");
	CodeWriter::writeLine("{", 1);

	// Define instance functions for use with the idFunc macro
	if (this->instanceFunctions.size() > 0)
	{
		for (Function* func : this->instanceFunctions.values)
			CodeWriter::writeLine("DefineObjectFunction(ID_" + String(this->name) + ", M_" + String(func->name) + ", " + String(func->toExecuteCpp()) + ")");
		CodeWriter::writeLine();
	}

	CodeWriter::writeLine("if (memberMap.contains(ID_" + String(this->name) + "))", 1);
	CodeWriter::writeLine("return;");
	CodeWriter::writeLine("", -1);

	// Define members
	for (Variable* var : this->instanceVars.values)
		CodeWriter::writeLine("DefineObjectMember(ID_" + String(this->name) + ", M_" + CodeObject::nameToCpp(var->name) + ", " + CodeObject::nameToCpp(var->name) + ", " + var->type->toCppEnum() + ");");

	CodeWriter::writeLine("}", -1);
	CodeWriter::writeLine();
}

}
