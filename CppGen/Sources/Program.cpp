#include "CppGen.hpp"

namespace CppGen
{
void Program::main(List<String> args)
{
	String repoDir = args.size() > 0
		? args[0]
		: fsString(fs::current_path().parent_path().parent_path());

	String jsonFile = args.size() > 1
		? args[1]
		: fsString(fs::current_path().parent_path())+ "/gml.json";

	String gmDir = repoDir + "/GmProject";

	if (DirectoryInfo(gmDir).getFiles("*.yyp").size() == 0)
	{
		Console::writeLine("FATAL ERROR: No GameMaker project found in {0}", gmDir);
		Environment::exit(1);
	}

	if (!File::exists(jsonFile))
	{
		Console::writeLine("FATAL ERROR: Could not find gml.json");
		Environment::exit(1);
	}

	String outputCodeDir = repoDir + "/CppProject/Generated";
	String outputSpritesDir = repoDir + "/CppProject/Asset/Sprites";
	String outputShadersDir = repoDir + "/CppProject/Asset/Shaders";

	Console::writeLine("Mine-imator GML -> C++ conversion begin");
	Console::writeLine("Input project: " + gmDir);
	Console::writeLine("Output folder: " + outputCodeDir);

	GML::parseGMLSpec(jsonFile);
	Program::strings.add("");

	// Parse sprites
	List<String> spriteDirs = Directory::getDirectories(gmDir + "/sprites");
	for (String dir : spriteDirs)
	{
		Sprite* spr = makeObject<Sprite>(dir, outputSpritesDir);
		Program::sprites.add(spr->name, spr);
	}

	if (Sprite::totalCopied > 0)
		Console::writeLine(Sprite::totalCopied + String(" sprite frames were copied"));
	else
		Console::writeLine("No sprites were updated");

	// Parse shaders
	if (Directory::exists(gmDir + "/shaders"))
	{
		List<String> shaderDirs = Directory::getDirectories(gmDir + "/shaders");
		for (String dir : shaderDirs)
		{
			Shader* shader = makeObject<Shader>(dir, outputShadersDir);
			if (shader->isValid)
				Program::shaders.add(shader->name, shader);
		}
	}

	if (Shader::modifications.size() > 0)
	{
		Console::writeLine("The following shaders were modified in the C++ project:");
		for (Shader::FileModification* mod : Shader::modifications)
			Console::writeLine("    " + mod->source);

		Console::writeLine("Do you want to copy them over to the GameMaker project? (y/n)");
		String input = Console::readLine();
		if (input.toLower().startsWith("y"))
		{
			for (Shader::FileModification* mod : Shader::modifications)
				File::copy(mod->source, mod->dest, true);
			Shader::totalCopied += Shader::modifications.size();
		}
	}

	if (Shader::totalCopied > 0)
		Console::writeLine(Shader::totalCopied + String(" shaders were copied"));
	else
		Console::writeLine("No shaders were updated");

	Stopwatch timer = Stopwatch();
	timer.start();

	// Parse script GML
	List<String> scriptDirs = Directory::getDirectories(gmDir + "/scripts");
	for (String dir : scriptDirs)
	{
		DirectoryInfo dirInfo = DirectoryInfo(dir);
		FileInfo gmlInfo = FileInfo(dir + "/" + dirInfo.name + ".gml");
		if (!gmlInfo.exists)
			continue;

		GML::parseGMLScript(gmlInfo.fullName);
	}

	timer.stop();
	Console::writeLine("Parsed GML ({0} lines) in {1}ms", GML::totalLines, (int)timer.elapsed.totalMilliseconds);

	// Parse objects
	List<String> objectDirs = Directory::getDirectories(gmDir + "/objects");
	for (String dir : objectDirs)
	{
		Object* obj = makeObject<Object>(dir);
		Program::objects[obj->name] = obj;
	}

	if (!Program::objects.containsKey("app"))
	{
		Console::writeLine("FATAL ERROR: app object not found");
		Environment::exit(1);
	}

	// Create constructors/destructors for GM objects that call their event/destroy event functions
	for (Object* obj : Program::objects.values)
	{
		obj->setConstructor(makeObject<Function>(obj->name));
		Program::functions.add(obj->name, obj->constructor);
		if (obj->createFunction != nullptr && obj->name != "app")
		{
			Function::currentParseFunction = obj->constructor;
			obj->constructor->statements->addStatement(makeObject<CallStatement>(makeObject<Accessor>(obj->createFunction->name, List<Accessor::ArrayAccessor*>(), List<Expression*>(), nullptr, Token::Type::Unknown, 1), 1));
		}

		if (obj->destroyFunction != nullptr)
		{
			obj->setDestructor(makeObject<Function>(obj->name));
			Program::functions.add("~" + obj->name, obj->destructor);
			Function::currentParseFunction = obj->destructor;
			obj->destructor->statements->addStatement(makeObject<CallStatement>(makeObject<Accessor>(obj->destroyFunction->name, List<Accessor::ArrayAccessor*>(), List<Expression*>(), nullptr, Token::Type::Unknown, 1), 1));
		}
	}

	Program::objects["app"]->constructor->cppLinesBegin.add("global::_app = this;"); // Define global app pointer

	timer.restart();
	for (Function* func : Program::functions.values)
		func->parseTokens();
	timer.stop();
	Console::writeLine("Parsed tokens in {0}ms", (int)timer.elapsed.totalMilliseconds);

	if (Program::functions.containsKey("enums"))
		Program::functions.remove("enums");
	if (Program::functions.containsKey("macros"))
		Program::functions.remove("macros");

	// Resolve macros
	for (MacroStatement* macro : Program::macros.values)
		macro->resolve(ResolveScope("global"));

	// Declare all globals found (empty type)
	for (DeclareStatement* declStmt : DeclareStatement::globalDeclarations)
		for (Declaration* decl : declStmt->declarations->declarations)
			declareVariable("global", decl->name, DataType(), declStmt->func, Statement::Location(), declStmt->line);

	timer.restart();
	resolveProject();
	WithStatement::resolveUnknownScope = true;
	Accessor::resolveFunctionReferences = true;
	Accessor::resolveUnknownScope = true;
	Accessor::resolveUnknownMapTypes = true;
	Function::enableAssignScope = true;
	Program::mergeUnknownVars = true;
	resolveProject();
	timer.stop();


	int percResolved = (int)((1.0f - Variable::variantVariables / (float)Variable::totalVariables) * 100.0f);
	Console::writeLine("Solved {0} out of {1} variable types ({2}%) in {3}ms", Variable::totalVariables - Variable::variantVariables, Variable::totalVariables, percResolved,(int)timer.elapsed.totalMilliseconds);

	timer.restart();

	// Generate GmlFunc.hpp
	GML::exportHeader(outputCodeDir + "/GmlFunc.hpp");

	// Generate Scripts.hpp
	CodeWriter::begin();
	CodeWriter::writeLine("#pragma once");
	CodeWriter::writeLine("#include \"GmlFunc.hpp\"");
	CodeWriter::writeLine();
	CodeWriter::writeLine("namespace CppProject");
	CodeWriter::writeLine("{", 1);

	for (MacroStatement* macroStmt : Program::macros.values)
		macroStmt->writeCpp(ResolveScope("global"));
	CodeWriter::writeLine();

	for (EnumStatement* enumStmt : Program::enums.values)
	{
		enumStmt->writeCpp(ResolveScope("global"));
		CodeWriter::writeLine();
	}

	CodeWriter::writeLine("struct app;");
	CodeWriter::writeLine("struct global");
	CodeWriter::writeLine("{", 1);
	CodeWriter::writeLine("static app* _app;");
	for (Variable* var : Program::globalVars.values)
		if (!Program::macros.containsKey(var->name))
			CodeWriter::writeLine("static " + var->type->toCpp() + " " + var->name + ";");
	CodeWriter::writeLine("};", -1);
	CodeWriter::writeLine();

	for (Object* obj : Program::objects.values)
	{
		obj->writeCppHeader();
		CodeWriter::writeLine();
	}

	for (Function* func : Program::functions.values)
		if (func->structObject == nullptr)
			func->writeCppHeader();

	DataType::ignoreAllVarType = true;
	if (Program::externalFunctions.size() > 0)
		CodeWriter::writeLine();
	for (ExternalFunction* extFunc : Program::externalFunctions.values)
		extFunc->writeCppHeader();
	DataType::ignoreAllVarType = false;

	int assetId = 20;
	CodeWriter::writeLine();
	for (Object* obj : Program::objects.values)
		CodeWriter::writeLine("#define ID_" + obj->name + " IntType(" + (assetId++) + ")");

	CodeWriter::writeLine();
	for (Sprite* sprite : Program::sprites.values)
		CodeWriter::writeLine("#define ID_" + sprite->name + " IntType(" + (assetId++) + ")");

	CodeWriter::writeLine();
	for (Shader* shader : Program::shaders.values)
		CodeWriter::writeLine("#define ID_" + shader->name + " IntType(" + (assetId++) + ")");

	CodeWriter::writeLine();
	for (Function* func : Program::functions.values)
		if (func->structObject == nullptr)
			CodeWriter::writeLine("#define ID_" + func->name + " IntType(" + (assetId++) + ")");

	List<String> members = List<String>();
	for (Object* obj : Program::objects.values)
	{
		for (String varName : obj->instanceVars.keys)
		{
			String cppName = CodeObject::nameToCpp(varName);
			if (!members.contains(cppName))
				members.add(cppName);
		}
		for (String funcName : obj->instanceFunctions.keys)
		{
			String cppName = CodeObject::nameToCpp(funcName);
			if (!members.contains(cppName))
				members.add(cppName);
		}
	}

	for (String varName : Program::unknownScopeVars.keys)
	{
		String cppName = CodeObject::nameToCpp(varName);
		if (!members.contains(cppName))
			members.add(cppName);
	}

	assetId = 0;
	members.sort();
	CodeWriter::writeLine();
	for (String mem : members)
		CodeWriter::writeLine("#define M_" + mem + " IntType(" + (assetId++) + ")");

	CodeWriter::writeLine();

	CodeWriter::writeLine("}", -1);
	CodeWriter::end(outputCodeDir + "/Scripts.hpp");

	// Declare Globals.cpp
	CodeWriter::begin();
	CodeWriter::writeLine("#include \"Scripts.hpp\"");
	CodeWriter::writeLine("#include \"Asset/Shader.hpp\"");
	CodeWriter::writeLine();
	CodeWriter::writeLine("namespace CppProject");
	CodeWriter::writeLine("{", 1);

	DataType::ignoreAllVarType = true;
	for (String var : GML::variables.keys)
		if (!GML::keywords.contains(var) && var != "argument" && var != "argument_count")
			CodeWriter::writeLine(GML::variables[var]->toCpp() + " gmlGlobal::" + var + " = " + GML::variables[var]->toCppDefaultValue() + ";");
	CodeWriter::writeLine();
	DataType::ignoreAllVarType = false;

	CodeWriter::writeLine("app* global::_app = nullptr;");
	for (Variable* var : Program::globalVars.values)
		if (!Program::macros.containsKey(var->name))
			CodeWriter::writeLine(var->type->toCpp() + " global::" + var->name + " = " + var->type->toCppDefaultValue() + ";");
	CodeWriter::writeLine();

	CodeWriter::writeLine("}", -1);
	CodeWriter::end(outputCodeDir + "/Globals.cpp");

	// Generate Scripts1...n.cpp
	const int maxLinePerFile = 1000;
	int f = 1;
	while (true)
	{
		CodeWriter::begin();
		CodeWriter::writeLine("#include \"Scripts.hpp\"");
		CodeWriter::writeLine();
		CodeWriter::writeLine("namespace CppProject");
		CodeWriter::writeLine("{", 1);

		for (Object* obj : Program::objects.values)
		{
			obj->writeCppImplementation();
			if (CodeWriter::lines > maxLinePerFile)
				break;
		}

		int funcWritten = 0;
		if (CodeWriter::lines <= maxLinePerFile)
		{
			for (Function* func : Program::functions.values)
			{
				if (func->structObject != nullptr || func->isCppSeparate)
					continue;

				if (func->writeCppImplementation())
					funcWritten++;

				if (CodeWriter::lines > maxLinePerFile)
					break;
			}

			if (funcWritten == 0)
				break; // Don't generate final file
		}

		CodeWriter::writeLine("}", -1);
		CodeWriter::end(outputCodeDir + "/Scripts" + f + ".cpp");
		f++;
	}

	// Delete unused
	while (true)
	{
		FileInfo file = FileInfo(outputCodeDir + "/Scripts" + f + ".cpp");
		if (file.exists)
			file.deleteFile();
		else
			break;
		f++;
	}

	// Generate Assets.cpp
	CodeWriter::begin();
	CodeWriter::writeLine("#include \"Asset/Script.hpp\"");
	CodeWriter::writeLine("#include \"Asset/Shader.hpp\"");
	CodeWriter::writeLine("#include \"Asset/Sprite.hpp\"");
	CodeWriter::writeLine("#include \"Scripts.hpp\"");
	CodeWriter::writeLine();
	CodeWriter::writeLine("#define AddSprite(name, numFrames, originX, originY) \\", 1);
	CodeWriter::writeLine("new Sprite(#name, ID_##name, numFrames, { originX, originY });");
	CodeWriter::indent(-1);
	CodeWriter::writeLine();
	CodeWriter::writeLine("#define AddShader(name) \\", 1);
	CodeWriter::writeLine("new Shader(#name, ID_##name);");
	CodeWriter::indent(-1);
	CodeWriter::writeLine();
	CodeWriter::writeLine("#define AddScript(name, ...) \\", 1);
	CodeWriter::writeLine("{ #name, ID_##name, +[](IntType s, IntType o, VarArgs a) -> VarType __VA_ARGS__ },");
	CodeWriter::indent(-1);
	CodeWriter::writeLine();
	CodeWriter::writeLine("namespace CppProject");
	CodeWriter::writeLine("{", 1);
	CodeWriter::writeLine("void Asset::Load()");
	CodeWriter::writeLine("{", 1);

	for (Sprite* spr : Program::sprites.values)
		CodeWriter::writeLine("AddSprite(" + spr->name + ", " + spr->numFrames + ", " + spr->originX + ", " + spr->originY + ");");

	CodeWriter::writeLine();
	for (Shader* shader : Program::shaders.values)
		CodeWriter::writeLine("AddShader(" + shader->name + ");");

	CodeWriter::writeLine();
	CodeWriter::writeLine("struct ScriptDefinition");
	CodeWriter::writeLine("{", 1);
	CodeWriter::writeLine("const char* name;");
	CodeWriter::writeLine("IntType id;");
	CodeWriter::writeLine("Script::ExecuteFunction function;");
	CodeWriter::writeLine("};", -1);
	CodeWriter::writeLine();
	CodeWriter::writeLine("static const ScriptDefinition scripts[] =");
	CodeWriter::writeLine("{", 1);
	for (Function* func : Program::functions.values)
		if (func->structObject == nullptr && !func->name.startsWith("builder_add_"))
			CodeWriter::writeLine("AddScript(" + func->name + ", " + func->toExecuteCpp() + ")");
	CodeWriter::writeLine("};", -1);
	CodeWriter::writeLine();
	CodeWriter::writeLine("for (const ScriptDefinition& script : scripts)", 1);
	CodeWriter::writeLine("new Script(script.name, script.id, script.function);");
	CodeWriter::indent(-1);

	CodeWriter::writeLine("}", -1);
	CodeWriter::writeLine("}", -1);
	CodeWriter::end(outputCodeDir + "/Assets.cpp");

	// Generate Objects1...n.cpp, splitting only between InitMembers() methods
	List<Object*> mappedObjects = List<Object*>(Program::objects.values);
	int mappedObject = 0;
	int objectFile = 1;
	while (mappedObject < static_cast<int>(mappedObjects.size()))
	{
		CodeWriter::begin();
		CodeWriter::writeLine("#include \"Scripts.hpp\"");
		CodeWriter::writeLine();
		CodeWriter::writeLine("#define DefineObjectMember(subAssetId, memberId, member, enumType) \\", 1);
		CodeWriter::writeLine("memberMap[subAssetId][memberId] = { enumType, (long long)&member - (long long)this };");
		CodeWriter::indent(-1);
		CodeWriter::writeLine();
		CodeWriter::writeLine("#define DefineObjectFunction(subAssetId, funcId, ...) \\", 1);
		CodeWriter::writeLine("instanceFuncMap[funcId] = [&](VarArgs a) __VA_ARGS__;");
		CodeWriter::indent(-1);
		CodeWriter::writeLine();
		CodeWriter::writeLine("namespace CppProject");
		CodeWriter::writeLine("{", 1);

		do
		{
			mappedObjects[mappedObject++]->writeInitMembers();
		}
		while (mappedObject < static_cast<int>(mappedObjects.size()) && CodeWriter::lines <= maxLinePerFile);

		CodeWriter::writeLine("}", -1);
		CodeWriter::end(outputCodeDir + "/Objects" + objectFile + ".cpp");
		objectFile++;
	}

	// Delete unused object mapping files left by an earlier, larger generation
	while (true)
	{
		FileInfo file = FileInfo(outputCodeDir + "/Objects" + objectFile + ".cpp");
		if (file.exists)
			file.deleteFile();
		else
			break;
		objectFile++;
	}

	// Generate AddGMLStrings.cpp
	CodeWriter::begin();
	CodeWriter::writeLine("#include \"Type/StringType.hpp\"");
	CodeWriter::writeLine();
	CodeWriter::writeLine("namespace CppProject");
	CodeWriter::writeLine("{", 1);
	CodeWriter::writeLine("void StringType::AddGMLStrings()");
	CodeWriter::writeLine("{", 1);
	for (String str : Program::strings)
		CodeWriter::writeLine("Add(\"" + str + "\");");
	CodeWriter::writeLine("}", -1);
	CodeWriter::writeLine("}", -1);
	CodeWriter::end(outputCodeDir + "/AddGMLStrings.cpp");

	// Finished
	timer.stop();
	Console::writeLine("Generated code ({0} lines) in {1}ms", CodeWriter::totalLines, (int)timer.elapsed.totalMilliseconds);
	Console::writeLine("{0} files were updated", CodeWriter::totalFilesUpdated);
	printDebugFiles();

	if (Program::syntaxErrors.size() > 0)
	{
		for (String err : Program::syntaxErrors)
			Console::writeLine("ERROR: " + err);
		Console::writeLine(String("Finished with ") + Program::syntaxErrors.size() + " errors");
	}
	else
		Console::writeLine("Success!");
}

void Program::resolveProject()
{
	// Mark unresolved
	for (Function* func : Program::functions.values)
		func->scopesTraversed.clear();
	for (Object* obj : Program::objects.values)
		for (Function* func : obj->instanceFunctions.values)
			func->scopesTraversed.clear();

	CodeObject::unknownScopes = 0;
	Program::unknownScopeVars.clear();
	Console::writeLine("Processing types...");

	while (true)
	{
		int passVariants = Variable::variantVariables;
		for (Function* func : Program::functions.values)
			func->isTraversed = false;
		for (Object* obj : Program::objects.values)
			for (Function* func : obj->instanceFunctions.values)
				func->isTraversed = false;

		// Resolve object constructors/destructors
		for (Object* obj : Program::objects.values)
		{
			if (obj->name == "app")
				continue;

			if (obj->constructor != nullptr)
				obj->constructor->resolve(ResolveScope(obj->name));

			if (obj->destructor != nullptr)
				obj->destructor->resolve(ResolveScope(obj->name));
		}

		Program::objects["app"]->constructor->resolve(ResolveScope("app"));

		// Resolve app functions
		if (Program::appDrawFunction != nullptr)
			Program::appDrawFunction->resolve(ResolveScope("app"));
		if (Program::appStepFunction != nullptr)
			Program::appStepFunction->resolve(ResolveScope("app"));
		if (Program::appHttpFunction != nullptr)
			Program::appHttpFunction->resolve(ResolveScope("app"));
		if (Program::appGameEndFunction != nullptr)
			Program::appGameEndFunction->resolve(ResolveScope("app"));

		// Resolve instance functions
		for (Object* obj : Program::objects.values)
			for (Function* func : obj->instanceFunctions.values)
				func->resolve(ResolveScope(obj->name));

		if (Program::mergeUnknownVars)
		{
			// Merge instance variables with other instance variables of same name declared in the same function scope
			for (Function* func : Program::functions.values)
			{
				for (int v = 0; v < static_cast<int>(func->instanceVarDecls.size()); v++)
				{
					Variable* v1 = func->instanceVarDecls[v];
					for (int vv = 0; vv < static_cast<int>(func->instanceVarDecls.size()); vv++)
					{
						if (v == vv)
							continue;

						Variable* v2 = func->instanceVarDecls[vv];
						if (v2->name == v1->name)
							v2->type->assign(*v1->type, func, 0);
					}
				}
			}

			// Merge unknown variables with instnace variables of same name
			for (Variable* unknownVar : Program::unknownScopeVars.values)
			{
				// Apply instance variables to unknown
				for (Object* obj : Program::objects.values)
					for (Variable* instVar : obj->instanceVars.values)
						if (unknownVar->name == instVar->name)
							unknownVar->assignType(*instVar->type, nullptr, 0);

				// Apply unknown variables to instances
				for (Object* obj : Program::objects.values)
					for (Variable* instVar : obj->instanceVars.values)
						if (unknownVar->name == instVar->name)
							instVar->assignType(*unknownVar->type, nullptr, 0);
			}
		}

		// Nothing was changed, break pass
		if (Variable::variantVariables == passVariants)
			break;
	}

	// Resolve unused functions in any scope
	if (Accessor::resolveFunctionReferences)
	{
		for (Function* func : Program::functions.values)
		{
			if (func->isUnused)
			{
				// Ensure scope is correct for block scripts
				if (func->name.startsWith("block_set_") || func->name.startsWith("block_tile_entity_"))
					func->resolve(ResolveScope("obj_builder_thread"));
				else
					func->resolve(ResolveScope("any"));
			}
		}
	}
}

Variable* Program::findVariable(String scope, String name, Function* func, const Statement::Location& location, int line, Function* funcAssignScope, bool includeUnknown)
{
	// Local or argument
	if (func != nullptr)
	{
		for (int i = func->vars.size() - 1; i >= 0; i--)
		{
			Variable* var = func->vars[i];
			if (var->name == name && var->location.contains(location)) // Name must match and be declared outside this location
			{
				if (var->line == 0 && func->varArgs && !func->varArgsRequiredNames.contains(name))
					func->varArgsRequiredNames.add(name);
				return var;
			}
		}

		// argument0..15
		if (name != "argument" && name != "argument_count" && name.startsWith("argument"))
		{
			int argNum = Convert::toInt32(name.replace("argument", ""));
			if (argNum >= 0 && static_cast<int>(func->vars.size()) > argNum && func->vars[argNum]->line == 0)
				return func->vars[argNum];
		}
	}

	// Unknown scope
	if (scope == "any" && includeUnknown && Program::unknownScopeVars.containsKey(name))
	{
		if (funcAssignScope != nullptr)
			funcAssignScope->assignScope(scope, func, line, true);
		return Program::unknownScopeVars[name];
	}

	// Instance (scope is object name)
	if (Program::objects.containsKey(scope))
	{
		if (Program::objects[scope]->instanceVars.containsKey(name))
		{
			Variable* var = Program::objects[scope]->instanceVars[name];
			if (funcAssignScope != nullptr)
			{
				if (!funcAssignScope->instanceVarDecls.contains(var)) // Add variable to function
					funcAssignScope->instanceVarDecls.add(var);
				funcAssignScope->assignScope(scope, func, line, true);
			}
			return var;
		}
	}

	// Global
	if (Program::globalVars.containsKey(name))
		return Program::globalVars[name];

	return nullptr;
}

Variable* Program::declareVariable(String scope, String name, const DataType& type, Function* func, const Statement::Location& location, int line, Function* funcAssignScope)
{
	// Unknown scope
	if (scope == "any")
	{
		if (!Program::unknownScopeVars.containsKey(name))
			Program::unknownScopeVars.add(name, makeObject<Variable>(scope, name, type, line, location));
		else
			Program::unknownScopeVars[name]->assignType(type, func, line);
		if (funcAssignScope != nullptr)
			funcAssignScope->assignScope(scope, func, line, true);
		return Program::unknownScopeVars[name];
	}

	// Global
	if (scope == "global")
	{
		if (!Program::globalVars.containsKey(name))
			Program::globalVars.add(name, makeObject<Variable>(scope, name, type, line, location));
		else
			Program::globalVars[name]->assignType(type, func, line);

		return Program::globalVars[name];
	}

	// Instance (scope is object name, and this is not an argument)
	if (Program::objects.containsKey(scope) && line > 0)
	{
		if (!Program::objects[scope]->instanceVars.containsKey(name))
			Program::objects[scope]->instanceVars.add(name, makeObject<Variable>(scope, name, type, line, location));
		else
			Program::objects[scope]->instanceVars[name]->assignType(type, func, line);

		Variable* var = Program::objects[scope]->instanceVars[name];
		if (funcAssignScope != nullptr)
		{
			if (!funcAssignScope->instanceVarDecls.contains(var)) // Add variable to function
				funcAssignScope->instanceVarDecls.add(var);
			funcAssignScope->assignScope(scope, func, line, true);
		}
		return var;
	}

	// Local (scope is function name)
	if (func != nullptr)
	{
		for (Variable* var : func->vars)
		{
			if (var->name != name)
				continue;

			if (var->line == line)  // Update pre-declared variable
			{
				var->assignType(type, func, line);
				return var;
			}
			else if (var->location.equals(location)) // Redeclared in the same scope
			{
				addSyntaxError("Variable " + name + " redeclared, previous on line " + var->line + " in " + func->name + ":" + line);
				return var;
			}
		}

		Variable* newVar = makeObject<Variable>(scope, name, type, line, location);
		func->vars.add(newVar);
		return newVar;
	}

	return nullptr;
}

void Program::addSyntaxError(String text)
{
	if (!Program::syntaxErrors.contains(text))
		Program::syntaxErrors.add(text);
}

void Program::printDebugFiles()
{
	// Debug global variables
	List<String> globalVarsStrings = List<String>();
	for (Variable* var : Program::globalVars.values)
		globalVarsStrings.add(var->type->toCpp() + " " + var->name + "\n" + var->type->getAssignmentsString("\t"));

	// Debug unknown variables
	List<String> unknownVarsStrings = List<String>();
	for (Variable* var : Program::unknownScopeVars.values)
		unknownVarsStrings.add(var->type->toCpp() + " " + var->name + "\n" + var->type->getAssignmentsString("\t"));

	// Debug functions
	List<String> funcsStrings = List<String>();
	for (Function* func : Program::functions.values)
		funcsStrings.add(func->toDebugString());

	// Debug objects
	List<String> objsStrings = List<String>();
	for (Object* obj : Program::objects.values)
		objsStrings.add(obj->toDebugString());

	globalVarsStrings.sort();
	unknownVarsStrings.sort();
	funcsStrings.sort();
	objsStrings.sort();
	String globalVarsText = "";
	String unknownVarsText = "";
	String funcsText = "";
	String objsText = "";
	for (String var : globalVarsStrings)
		globalVarsText += var;
	for (String var : unknownVarsStrings)
		unknownVarsText += var;
	for (String func : funcsStrings)
		funcsText += func + "\n";
	for (String obj : objsStrings)
		objsText += obj + "\n";

#ifndef NDEBUG
	// Allocation instrumentation is deliberately debug-only. RTTI name lookup
	// and map updates are too expensive to execute in production solver passes.
	List<String> allocationStrings;
	std::size_t totalAllocations = 0;
	for (const auto& [className, count] : objectArena().allocationCounts())
	{
		allocationStrings.add(String(className) + ": " + toStringValue(count));
		totalAllocations += count;
	}
	allocationStrings.sort();
	String allocationsText = "Total: " + toStringValue(totalAllocations) + "\n";
	for (const String& allocation : allocationStrings)
		allocationsText += allocation + "\n";
#endif

	String logDir = Directory::getCurrentDirectory() + "/Logs";
	Directory::createDirectory(logDir);
	Console::writeLine("Writing logs to {0}", logDir);
	File::writeAllText(logDir + "/globalVars.log", globalVarsText);
	File::writeAllText(logDir + "/unknownVars.log", unknownVarsText);
	File::writeAllText(logDir + "/funcs.log", funcsText);
	File::writeAllText(logDir + "/objs.log", objsText);
#ifndef NDEBUG
	File::writeAllText(logDir + "/allocations.log", allocationsText);
#endif
}

}
