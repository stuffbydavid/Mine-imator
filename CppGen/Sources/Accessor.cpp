#include "CppGen.hpp"

namespace CppGen
{
Accessor::Accessor(String name, List<Accessor::ArrayAccessor*> arrayAccessors, List<Expression*> callParameters, Accessor* member, Token::Type addSubOp, int line) : Expression(line)
{
	this->name = name;
	this->arrayAccessors = arrayAccessors;
	this->callParameters = callParameters;
	this->nextInChain = member;
	if (this->nextInChain != nullptr)
	{
		this->addSubOp = this->nextInChain->addSubOp;
		this->nextInChain->previousInChain = this;
	}
	else
	{
		this->addSubOp = addSubOp;
		if (this->addSubOp != Token::Type::Unknown)
			markAsAssign(this);
	}
	type = Type::Accessor;
}

void Accessor::markAsAssign(Expression* expr)
{
	this->assignExpr = expr;
	if (this->nextInChain) this->nextInChain->markAsAssign(expr);
}

void Accessor::resolve(ResolveScope* scope)
{
	if (Program::enums.containsKey(this->name)) // Enums are always integer
	{
		this->resolvedType->reset(DataType::Type::Integer);
		return;
	}

	this->resolvedType->reset();
	Function* userFunction = getUserFunction(scope);
	DataType::Type accessorType = DataType::Type::Array;
	Variable* var = nullptr;

	// Function* call
	if (this->callParameters != nullptr)
	{
		List<DataType> inputTypeStorage;
		inputTypeStorage.reserve(this->callParameters.size());
		for (Expression* expr : this->callParameters) // Resolve expressions into types
		{
			expr->resolve(scope->outsideChain()); // use outside scope for instance methods
			inputTypeStorage.add(DataType(*expr->resolvedType));
		}
		List<DataType*> inputTypes;
		inputTypes.reserve(inputTypeStorage.size());
		for (DataType& inputType : inputTypeStorage)
			inputTypes.add(&inputType);

		if (userFunction != nullptr) // User function
		{
			if (scope->location->level == 0 && !userFunction->sameScopeFunctions.contains(this->func) && userFunction != this->func) // Make this function dependent if outside with()
				userFunction->sameScopeFunctions.add(this->func);
			userFunction->resolve(ResolveScope(*scope, this->func->name, this->line), inputTypes, this->func, this->line);
			if (scope->location->level == 0 && userFunction->hasInstanceVars)
				this->func->assignFunctionScope(userFunction, this->func, this->line);

			if (this->name == "new_obj") // new_obj(objName) returns reference<objName>
			{
				if (this->callParameters.size() != 1 || this->callParameters[0]->type != Type::Accessor)
				{
					Console::writeLine("FATAL ERROR: Invalid input to new_obj() in {0}:{1}", this->func->name, this->line);
					Environment::exit(1);
				}

				String objName = static_cast<Accessor*>(this->callParameters[0])->name;
				if (!Program::objects.containsKey(objName))
				{
					Console::writeLine("FATAL ERROR: Unknown object in new_obj() in {0}:{1}: {2}", this->func->name, this->line, objName);
					Environment::exit(1);
				}
				this->resolvedType->reset(DataType::Type::Reference, objName);
			}

			else if (this->name == "array_add") // array_add(array<typeof arg>, arg/array>
			{
				if (this->callParameters.size() < 2 || this->callParameters.size() > 3)
				{
					Console::writeLine("FATAL ERROR: Invalid input to array_add() in {0}:{1}", this->func->name, this->line);
					Environment::exit(1);
				}

				DataType arrTypeStorage;
				DataType* arrType = &arrTypeStorage;
				int i = 0;
				for (DataType* inputType : inputTypes)
					if (i++ > 0)
						arrType->assign(*inputType, this->func, this->line);
				if (arrType->cppType == DataType::CppType::ArrType) // User gave array of values to add, fetch container type
					arrType = arrType->getFirstAssignment(DataType::Type::Array)->containerType;
				this->callParameters[0]->applyType(scope, DataType(DataType::Type::Array, arrType)); // Apply to 1st parameter
				if (this->callParameters[0]->type == Type::Accessor)
					static_cast<Accessor*>(this->callParameters[0])->markAsAssign(this);
				this->resolvedType->reset(*userFunction->getReturnType());
			}

			else if (this->name == "array") // array(arg0, arg1...) returns array<typeof args>
			{
				this->resolvedType->reset(DataType::Type::Array, DataType());
				for (DataType* inputType : inputTypes)
					this->resolvedType->assign(DataType(DataType::Type::Array, inputType), this->func, this->line);
			}
			else if (this->name == "save_id_find") // save_id_find returns unknown object
				this->resolvedType->reset(DataType::Type::Reference, "");

			else if (this->name == "ds_int_map_create") // ds_int_map_create returns IntMap
				this->resolvedType->reset(DataType::Type::IntMap, DataType());

			else if (this->name == "ds_string_map_create" || this->name == "json_load") // ds_string_map_create/json_load returns StringMap
				this->resolvedType->reset(DataType::Type::StringMap, DataType());

			else if (this->name == "test") // test(bool, arg1, arg2) returns typeof arg1
				this->resolvedType->reset(*inputTypes[1]);

			else
				this->resolvedType->reset(*userFunction->getReturnType());
		}
		else if (GML::functions.containsKey(this->name)) // Built-in function, look up GML* spec
		{
			GML::FunctionSignature* funcSign = GML::functions[this->name];
			this->resolvedType->reset(*funcSign->returnType);

			if (!funcSign->varArgs && inputTypes.size() != funcSign->argTypes.size()) // Check argument match
			{
				Console::writeLine("FATAL ERROR: Argument count mismatch in {0}:{1}: {2}", this->func->name, this->line, this->name);
				Environment::exit(1);
			}

			if (funcSign->needScope && scope->location->level == 0 && this->func->getScope() == "global") // GML* function needs scope, mark global function as any
				this->func->assignScope("any", this->func, this->line);

			if (this->name == "array_create") // array_create(real, [arg]) returns array<typeof arg>
				if (inputTypes.size() > 1)
					this->resolvedType->reset(DataType::Type::Array, inputTypes[1]);
				else
					this->resolvedType->reset(DataType::Type::Array, DataType());

			else if (this->name == "array_length") // array_length returns int, don't apply arguments (since sub-arrays are the same type as array for ArrType)
			{
				this->resolvedType->reset(DataType::Type::Integer);
				if (this->callParameters[0]->type == Type::Accessor)
					static_cast<Accessor*>(this->callParameters[0])->markAsAssign(this);
			}

			else if (this->name == "choose" || this->name == "max" || this->name == "min") // choose/min/max(arg0, arg1...) returns typeof args
			{
				if (this->name != "choose")
					this->resolvedTypeCpp = DataType::CppType::RealType;
				for (DataType* inputType : inputTypes)
					this->resolvedType->assign(*inputType, this->func, this->line);
			}
			else if (this->name == "ds_list_add") // ds_list_add(list<typeof args>, arg0, arg1...)
			{
				DataType listType;
				int i = 0;
				for (DataType* inputType : inputTypes)
					if (i++ > 0)
						listType.assign(*inputType, this->func, this->line);
				this->callParameters[0]->applyType(scope, DataType(DataType::Type::List, &listType));
			}
			else if (this->name == "ds_map_find_first" || this->name == "ds_map_find_next" || this->name == "ds_map_find_value") // ds_map_find_x(map<type>, [ key ]) returns type
			{
				DataType::Assignment* mapAss = inputTypes[0]->getFirstAssignment(DataType::Type::AnyMap);
				if (mapAss != nullptr)
					this->resolvedType->assign(*mapAss->containerType, this->func, this->line);
			}
			else if (this->name == "ds_map_add") // ds_map_add(map<typeof arg>, key, arg)
			{
				DataType mapType;
				int i = 0;
				for (DataType* inputType : inputTypes)
					if (i++ > 1)
						mapType.assign(*inputType, this->func, this->line);
				this->callParameters[0]->applyType(scope, DataType(DataType::Type::AnyMap, &mapType));
			}
			else if (this->name == "ds_stack_push") // ds_stack_push(stack<typeof args>, arg0, arg1...)
			{
				DataType stackType;
				int i = 0;
				for (DataType* inputType : inputTypes)
					if (i++ > 0)
						stackType.assign(*inputType, this->func, this->line);
				this->callParameters[0]->applyType(scope, DataType(DataType::Type::Stack, &stackType));
			}
			else if (this->name == "ds_grid_set") // ds_grid_set(grid<typeof arg>, real, real, arg)
				this->callParameters[0]->applyType(scope, DataType(DataType::Type::Grid, inputTypes[3]));

			else if (this->name == "ds_grid_get") // ds_grid_get(grid<type>, x, y) returns type
			{
				DataType::Assignment* mapAss = inputTypes[0]->getFirstAssignment(DataType::Type::Grid);
				if (mapAss != nullptr)
					this->resolvedType->assign(*mapAss->containerType, this->func, this->line);
			}
			else if (this->name == "ds_list_copy" || this->name == "ds_map_copy") // ds_x_copy(ds1, typeof ds1)
				this->callParameters[0]->applyType(scope, *inputTypes[1]);

			else if (this->name == "shader_set_uniform_f" || this->name == "shader_set_uniform_i") // shader_set_uniform_f(real, real0, real1...)
			{
				for (Expression* expr : this->callParameters)
					expr->applyType(scope, DataType(DataType::Type::Real));
			}
			// We know the types of all GML* function arguments, apply them to the call parameter expressions
			else if (!funcSign->varArgs)
			{
				int i = 0;
				for (Expression* expr : this->callParameters)
					expr->applyType(scope, *funcSign->argTypes[i++]);
			}
		}
		else if (this->previousInChain == nullptr) // Missing function
		{
			Console::writeLine("FATAL ERROR: Missing function {2} in {0}:{1}", this->func->name, this->line, this->name);
			Environment::exit(1);
			return;
		}
	}

	else if (Program::objects.containsKey(this->name))
	{
		if (this->name == "app") // Pointer to app instance (_app in C++)
			this->resolvedType->reset(DataType::Type::Reference, "app");

		else // Object* reference as integer id
			this->resolvedType->reset(DataType::Type::Integer);
	}

	else if (userFunction != nullptr) // Function* reference
	{
		if (Accessor::resolveFunctionReferences) // Resolve after first pass in any scope
		{
			userFunction->assignScope("any", this->func, this->line);
			userFunction->resolve(ResolveScope(ResolveScope("any"), this->func->name, this->line), nullptr, this->func, this->line);
		}
		this->resolvedType->reset(DataType::Type::Integer);
	}

	else if (Program::shaders.containsKey(this->name) ||
			 Program::sprites.containsKey(this->name)) // Resource reference, treat as integer
		this->resolvedType->reset(DataType::Type::Integer);

	else if (this->name == "id" || this->name == "self") // Scope reference
	{
		if (scope->location->level == 0 && this->previousInChain == nullptr) // Update function scope if outside with()
			this->func->assignScope(scope->current, this->func, this->line, true);
		if (Program::objects.containsKey(scope->currentInChain))
			this->resolvedType->reset(DataType::Type::Reference, scope->currentInChain);
	}
	else if (this->name == "other") // Previous scope reference
	{
		this->resolvedType->reset(DataType::Type::Reference, scope->previous);
		if (scope->location->level == 1)
			this->func->hasInstanceVars = true;
	}
	else if (this->name == "object_index") // Type name
		this->resolvedType->reset(DataType::Type::Integer);

	else // Variable* reference
	{
		if (GML::variables.containsKey(this->name)) // Built-in variable
			this->resolvedType->reset(*GML::variables[this->name]);

		else if (GML::constants.containsKey(this->name)) // Built-in constant
		{
			bool isInt = (std::floor(GML::constants[this->name]) == GML::constants[this->name]); // Integer or Real?
			this->resolvedType->reset(isInt ? DataType::Type::Integer : DataType::Type::Real);
		}
		else // Project variable
		{
			Function* findVarFunc = (this->previousInChain != nullptr ? nullptr : this->func); // Local variables only visible for first accessor in chain
			Function* funcUpdateScope = (this->previousInChain != nullptr ? nullptr : scope->funcUpdateScope);
			var = Program::findVariable(scope->currentInChain, this->name, findVarFunc, *scope->location, this->line, funcUpdateScope);

			if (var == nullptr) // Declare new
				var = Program::declareVariable(scope->currentInChain, this->name, *this->resolvedType, this->func, *scope->location, this->line, funcUpdateScope);

			// Try to find container type
			if (this->arrayAccessors.size() > 0)
			{
				accessorType = this->arrayAccessors[0]->type;
				this->resolvedType->reset(accessorType, DataType()); // Get type from accessor value

				if (accessorType == DataType::Type::AnyMap) // Get map type
				{
					this->arrayAccessors[0]->expr->resolve(scope->outsideChain());
					DataType* exprType = this->arrayAccessors[0]->expr->resolvedType;
					if (exprType->cppType == DataType::CppType::StringType) // Accessor* is String
						this->resolvedType->reset(DataType::Type::StringMap, DataType());
					else if (exprType->cppType == DataType::CppType::IntType) // Accessor* is int
						this->resolvedType->reset(DataType::Type::IntMap, DataType());
					else if (Accessor::resolveUnknownMapTypes) // Variant map
						this->resolvedType->reset(DataType::Type::Map, DataType());
				}
				else if (this->arrayAccessors[0]->expr->type == Type::Accessor) // Get vector/matrix
				{
					Accessor* expr1 = static_cast<Accessor*>(this->arrayAccessors[0]->expr);
					if (expr1->name.startsWith("PATH_"))
					{
						accessorType = DataType::Type::Array;
						this->resolvedType->reset(DataType::Type::Variant);
					}
					else if (expr1->name == "X" || expr1->name == "Y" || expr1->name == "Z" || expr1->name == "W") // Vector
					{
						accessorType = DataType::Type::Vector;
						this->resolvedType->reset(DataType::Type::Vector, DataType(DataType::Type::Real));
					}
					else if (expr1->name == "MAT_X" || expr1->name == "MAT_Y" || expr1->name == "MAT_Z") // Matrix
					{
						accessorType = DataType::Type::Matrix;
						this->resolvedType->reset(DataType::Type::Matrix, DataType(DataType::Type::Real));
					}
				}
			}

			if (this->arrayAccessors.size() > 0) // Convert to array/ds if not container
				var->assignType(*this->resolvedType, this->func, this->line);

			else if (this->nextInChain != nullptr) // Assign reference
				var->assignType(DataType(DataType::Type::Reference, var->type->getUniqueReferenceId()), this->func, this->line);

			else if (this->addSubOp != Token::Type::Unknown) // Convert to Integer for ++/-- (last in chain only)
			{
				if (this->arrayAccessors.size() > 0)
				{
					DataType integerType(DataType::Type::Integer);
					var->assignType(DataType(this->arrayAccessors[0]->type, &integerType), this->func, this->line);
				}
				else
					var->assignType(DataType(DataType::Type::Integer), this->func, this->line);
			}

			this->resolvedType->reset(*var->type);
		}

		// Has accessors
		if (this->arrayAccessors.size() > 0)
		{
			for (ArrayAccessor* acc : this->arrayAccessors) // Resolve accessors
			{
				acc->expr->resolve(scope->outsideChain());
				if (accessorType != DataType::Type::AnyMap) // Array accessors should be integers
					acc->expr->applyType(scope->outsideChain(), DataType(DataType::Type::Integer));
			}

			if (var != nullptr && this->arrayAccessors[0]->isReference && this->assignExpr != nullptr)
				var->markReference();

			// Check if Value() is used
			if (this->resolvedType->cppType != DataType::CppType::VecType && this->resolvedType->cppType != DataType::CppType::MatrixType)
				this->resolvedTypeCpp = DataType::CppType::VarType;

			if (this->resolvedType->isContainer()) // Get type from array/ds container
			{
				List<DataType::Assignment> assignments = this->resolvedType->assignments;
				this->resolvedType->reset(); // Reset type

				for (DataType::Assignment& ass : assignments) // Assign all container types that match the accessors
				{
					if (accessorType == ass.rawType ||
						(accessorType == DataType::Type::AnyMap && DataType::isRawTypeMap(ass.rawType)) ||
						(accessorType == DataType::Type::Array && DataType::isRawTypeArray(ass.rawType)))
						this->resolvedType->assign(*ass.containerType, this->func, this->line);
				}

				if (this->resolvedType->isUnknown()) // ds[unknown] -> variant
					this->resolvedType->reset(DataType::Type::Variant);

			}
			else
				Program::addSyntaxError("Used [] on non-container type " + this->name + " in " + this->func->name + ":" + this->line);
		}
	}

	if (this->nextInChain != nullptr) // Resolve next in chain recursively
	{
		String nextInChainScope = getNextInChainScope(scope);
		if (nextInChainScope == "any")
		{
			CodeObject::unknownScopes++;
			this->resolvedType->reset();
			if (!Accessor::resolveUnknownScope)
				return;
		}

		if (this->nextInChain) this->nextInChain->resolve(scope->nextInChain(nextInChainScope));
		this->resolvedType = this->nextInChain->resolvedType;
		this->resolvedTypeCpp = this->nextInChain->resolvedTypeCpp;
	}

	if (this->assignExpr != nullptr)
		this->assignExpr->assignedTo = var;
}

bool Accessor::applyType(ResolveScope* scope, const DataType& inputType)
{
	if (Program::enums.containsKey(this->name)) // Skip enums
		return false;

	bool changed = false;
	if (this->nextInChain != nullptr)  // Apply to next in chain only
	{
		String nextInChainScope = getNextInChainScope(scope);
		if (nextInChainScope == "any")
		{
			CodeObject::unknownScopes++;
			if (!Accessor::resolveUnknownScope)
				return false;
		}

		return this->nextInChain->applyType(scope->nextInChain(nextInChainScope), inputType);
	}

	const DataType* appliedType = &inputType;
	std::optional<DataType> containerType;
	if (this->arrayAccessors.size() > 0) // Convert to container type
	{
		containerType.emplace(this->arrayAccessors[0]->type, const_cast<DataType*>(&inputType));
		appliedType = &*containerType;
	}

	// Function* call
	if (this->callParameters != nullptr)
	{
		Function* userFunction = getUserFunction(scope);
		if (userFunction != nullptr) // Update return type
			userFunction->assignReturnType(*appliedType, this->func, this->line);
	}
	else if (!GML::constants.containsKey(this->name) && !GML::variables.containsKey(this->name) &&
			 !Program::objects.containsKey(this->name) && !Program::macros.containsKey(this->name)) // User variable
	{
		Function* findVarFunc = (this->previousInChain != nullptr ? nullptr : this->func); // Local variables only visible for first accessor in chain
		Function* funcUpdateScope = (this->previousInChain != nullptr ? nullptr : scope->funcUpdateScope);
		Variable* var = Program::findVariable(scope->currentInChain, this->name, findVarFunc, *scope->location, this->line, funcUpdateScope);

		if (var != nullptr) // Apply type to variable
			changed = var->assignType(*appliedType, this->func, this->line);
		else // Declare new
			var = Program::declareVariable(scope->currentInChain, this->name, *appliedType, this->func, *scope->location, this->line, funcUpdateScope);

		if (this->assignExpr != nullptr)
			this->assignExpr->assignedTo = var;
	}

	return changed;
}

String Accessor::toCpp(ResolveScope* scope)
{
	String cpp = "";
	if (Program::enums.containsKey(this->name)) // Enum (with prefix)
		return nameToCpp(this->name) + "_" + nameToCpp(this->nextInChain->name);

	// external_call(name, [args...])
	if (this->name == "external_call" && this->callParameters != nullptr && this->callParameters.size() > 0)
	{
		Accessor* callAcc = static_cast<Accessor*>(this->callParameters[0]);
		if (!Program::externalFunctions.containsKey(callAcc->name))
		{
			Program::syntaxErrors.add("external_call on unknown function " + callAcc->name + " in " + this->func->name + ":" + this->line);
			return "";
		}

		String callCpp = callAcc->name + "(";
		for (int i = 1; i < static_cast<int>(this->callParameters.size()); i++)
			callCpp += (i > 1 ? ", " : "") + this->callParameters[i]->toCpp(scope);
		callCpp += ")";
		return callCpp;
	}

	// ord("X") -> (int)'X'
	if (this->name == "ord" && this->callParameters.size() > 0 && this->callParameters[0]->type == Type::Value)
	{
		ExpressionValue* value = static_cast<ExpressionValue*>(this->callParameters[0]);
		if (value->valueType == Token::Type::String)
			return "(IntType)'" + value->value + "'";
	}

	// current_time -> current_time()
	if (this->name == "current_time")
		return "current_time()";

	// new_obj(objName) -> (new objName)->id
	if (this->name == "new_obj")
		return "(new " + static_cast<Accessor*>(this->callParameters[0])->name + ")->id";

	// test(bool, val1, val2) -> ((bool) ? val1 : val2)
	if (this->name == "test")
		return "(" + toTernaryCpp(scope, this->callParameters[0], this->callParameters[1], this->callParameters[2]) + ")";

	if (Program::sprites.containsKey(this->name) ||
		Program::shaders.containsKey(this->name)) // Convert resource names to integer id
		return "ID_" + this->name;

	bool funcInstance = false;
	if (this->name != "app" && Program::objects.containsKey(this->name)) // Objects to integer id (except app and new expresisons)
	{
		if (Program::objects[this->name]->isStruct)
			funcInstance = true;
		else
			return "ID_" + this->name;
	}

	if (!this->lastToCppScopeSet && this->nextInChain != nullptr) // Generate C++ in chain from last to first on first call
	{
		this->lastToCppScope = *scope; // Save scope
		this->lastToCppScopeSet = true;
		String nextInChainScope = getNextInChainScope(scope);
		cpp = this->nextInChain->toCpp(scope->nextInChain(nextInChainScope));
		this->needLtZero = this->nextInChain->needLtZero;
		this->writtenType = this->nextInChain->writtenType;
		return cpp;
	}

	if (this->lastToCppScopeSet) // Restore scope
		scope = &this->lastToCppScope;

	bool thisPtrValid = (scope->location->level == 0 && this->func->structObject != nullptr); // In struct method outside any with()

	if (this->name == "app") // app instance id
		return this->appToId ? "global::_app->id" : "ID_app";

	if (this->name == "other") // other instance id
		return "self.otherId";

	if (this->name == "id" || this->name == "self" || this->name == "object_index") // id/object_index
	{
		if (this->previousInChain != nullptr)
		{
			if (this->name == "object_index") // Get assetId from chain
				return "Obj(" + this->previousInChain->toCpp(scope) + ")->subAssetId";
			else
				return this->previousInChain->toCpp(scope); // Previous chain should give an int for the id
		}
		else
		{
			String mem = (this->name == "object_index" ? "subAssetId" : "id");
			if (thisPtrValid)
				return mem;
			else if (scope->current == "app")
				return "global::_app->" + mem;
			else
				return "self->" + mem;
		}
	}

	Object* scopeObj = Program::objects.containsKey(scope->currentInChain) ? Program::objects[scope->currentInChain] : nullptr;
	Function* targetFunc = nullptr;
	GML::FunctionSignature* funcSign = nullptr;
	bool varArgs = false;
	String parCpp = "";
	bool parenthesis = true;
	String accessorFunc = "";

	if (GML::constants.containsKey(this->name) || GML::keywords.contains(this->name) || this->name == "argument" || this->name == "argument_count") // GML* Keyword
		cpp += nameToCpp(this->name);

	else if (GML::variables.containsKey(this->name)) // Global GML* variable
	{
		cpp += "gmlGlobal::" + nameToCpp(this->name);
		if (GML::variables[this->name]->getFirstAssignment()->rawType == DataType::Type::Map)
			cpp = "DsMap(" + cpp + ")";
	}

	else if (this->name != "argument" && this->name != "argument_count" && this->name.startsWith("argument")) // argument0..15
	{
		int argNum = Convert::toInt32(this->name.replace("argument", ""));
		if (argNum >= 0 && static_cast<int>(this->func->vars.size()) > argNum && this->func->vars[argNum]->line == 0)
			cpp += this->func->vars[argNum]->name;
		else
			Program::addSyntaxError("Invalid " + this->name + " in " + this->func->name + ":" + this->line);
	}
	else if (GML::functions.containsKey(this->name)) // GML* function
	{
		if (this->name == "ds_map_create" && this->assignedTo != nullptr) // Convert map creation to specific map type
		{
			DataType::Type varMapType = this->assignedTo->type->getMapType();
			if (varMapType == DataType::Type::IntMap)
				cpp += "ds_int_map_create";
			else if (varMapType == DataType::Type::StringMap)
				cpp += "ds_string_map_create";
			else
				cpp += this->name;
		}
		else
			cpp += nameToCpp(this->name);

		funcSign = GML::functions[this->name];
		varArgs = funcSign->varArgs;
	}

	else if (Program::functions.containsKey(this->name)) // User script
	{
		if (this->callParameters == nullptr) // Script name, convert to integer id
			return "ID_" + this->name;

		targetFunc = Program::functions[this->name];
		varArgs = targetFunc->varArgs;

		if (this->name == "array") // array(args) -> ArrType::From({ args })
		{
			if (this->callParameters.size() == 0) // array() -> ArrType()
				return "ArrType()";
			cpp += "ArrType::From";
		}
		else
			cpp += nameToCpp(this->name);
	}

	else if (scopeObj != nullptr && scopeObj->instanceFunctions.containsKey(this->name)) // Instance function
	{
		targetFunc = scopeObj->instanceFunctions[this->name];
		if (this->previousInChain != nullptr && this->previousInChain->name != "self") // Ptr from chain
			cpp += "ObjType(" + scopeObj->name + ", " + this->previousInChain->toCpp(scope) + ")->";
		cpp += nameToCpp(this->name);
		funcInstance = true;
	}

	else if (this->callParameters != nullptr) // Instance function in unknown scope
	{
		bool foundFuncAnywhere = false;
		for (Object* obj : Program::objects.values)
		{
			for (Function* instFunc : obj->instanceFunctions.values)
			{
				if (instFunc->name == this->name)
				{
					foundFuncAnywhere = true;
					break;
				}
			}
		}
		if (!foundFuncAnywhere || this->previousInChain == nullptr)
			Console::writeLine("FATAL ERROR: Unknown function {2} in {0}:{1}", this->func->name, this->line, this->name);

		// Get id from chain and feed into idFunc macro
		cpp += "idFunc(" + this->previousInChain->toCpp(scope) + ", " + this->name + ")";
		varArgs = true;
		if (this->callParameters.size() == 0)
			parCpp = "(ArrType())";

	}
	else // Variable (global, local, instance or unknown)
	{
		Function* findVarFunc = (this->previousInChain != nullptr ? nullptr : this->func); // Local variables only visible for first accessor in chain
		Variable* var = Program::findVariable(scope->currentInChain, this->name, findVarFunc, *scope->location, this->line, nullptr, false);
		String macroName = "";

		if (var != nullptr)
		{
			this->writtenType = var->type;
			if (var->scope == "app") // App
				cpp += "global::_app->" + nameToCpp(this->name);

			else if (scopeObj != nullptr && this->previousInChain != nullptr && this->previousInChain->name != "app" && this->previousInChain->name != "self") // Ptr from chain
				cpp += "ObjType(" + scopeObj->name + ", " + this->previousInChain->toCpp(scope) + ")->" + nameToCpp(this->name);

			else if (var->scope == "global") // Global/Macro
			{
				if (!Program::macros.containsKey(this->name))
					cpp += "global::";
				cpp += nameToCpp(this->name);
			}

			else if (var->scope == this->func->name || (thisPtrValid && var->scope == this->func->structObject->name)) // Instance (with same scope)
			{
				cpp += nameToCpp(this->name);
				if (var->isReference) // Get array/vector/matrix reference
				{
					if (this->assignExpr != nullptr) // arr[@i] = x
						cpp += ".Arr()"; // var->Arr()[i] = x
					else if (this->arrayAccessors.size() == 1) // arr[@i] = value
						accessorFunc = "Ref"; // arr.Ref(i) = value
				}
			}
			else // Scope variable
				cpp += "self->" + nameToCpp(this->name);
		}
		else // Unresolved scope, use member macro
		{
			bool foundVarAnywhere = Program::unknownScopeVars.containsKey(this->name);
			for (Object* obj : Program::objects.values)
			{
				if (obj->instanceVars.containsKey(this->name))
				{
					this->writtenType->assign(*obj->instanceVars[this->name]->type, nullptr, 0);
					foundVarAnywhere = true;
				}
			}
			if (!foundVarAnywhere)
				Console::writeLine("WARNING: Unknown variable {2} in {0}:{1}", this->func->name, this->line, this->name);
			macroName = this->writtenType->toCppMemberMacro();
		}

		// Check if > 0 is needed in conditions
		if (!Program::macros.containsKey(this->name))
			if (this->writtenType->cppType == DataType::CppType::IntType ||
				this->writtenType->cppType == DataType::CppType::RealType ||
				this->writtenType->cppType == DataType::CppType::VarType)
				this->needLtZero = true;

		if (macroName != "") // Create macro
		{
			if (this->previousInChain != nullptr) // Id from chain
				cpp += "id" + macroName + "(" + this->previousInChain->toCpp(scope) + ", " + nameToCpp(this->name) + ")";
			else // Id from Scope variable
				cpp += "s" + macroName + "(" + nameToCpp(this->name) + ")";
		}

		if (this->arrayAccessors.size() == 1)
		{
			// Prefer Real() for vector/matrix operations
			if (this->writtenType->cppType == DataType::CppType::VecType || this->writtenType->cppType == DataType::CppType::MatrixType)
				accessorFunc = "Real";

			else // Data structure lookup
			{
				DataType::Type dsType = DataType::Type::Unknown;
				if (var != nullptr) // Look for ds in assignments
					for (DataType::Assignment& ass : var->type->assignments)
						if (ass.rawType >= DataType::Type::List)
							dsType = ass.rawType;

				if (this->arrayAccessors[0]->type >= DataType::Type::Array) // Look for ds accessor
					dsType = this->arrayAccessors[0]->type;

				if (dsType != DataType::Type::Unknown)
				{
					// Wrap in DsX macro
					if (dsType == DataType::Type::List)
						cpp = "DsList(" + cpp + ")";
					else if (dsType == DataType::Type::AnyMap)
						cpp = "DsMap(" + cpp + ")";
					else if (dsType == DataType::Type::Grid)
						cpp = "DsGrid(" + cpp + ")";
				}

				// Prefer .Value(index/key) const for read-only
				if (this->assignExpr == nullptr)
					accessorFunc = "Value";
			}
		}
	}

	if (this->callParameters != nullptr && parCpp == "") // Parameters
	{
		int p = 0;
		if (parenthesis)
			parCpp += "(";

		String funcScope = "global";
		if (targetFunc != nullptr)
			funcScope = targetFunc->getScope();
		else if (funcSign != nullptr && funcSign->needScope)
			funcScope = "any";

		if (funcScope != "global" && funcScope != "app" && !funcInstance) // Send in scope for non-global/non-instance
		{
			if (thisPtrValid || scope->current != funcScope) // Make new scope
			{
				String scopeType, scopeArgs = "self";

				if (funcScope != "any") // Scope<T> struct
				{
					scopeType = "<" + funcScope + ">";
					if (thisPtrValid && this->func->structObject->name == funcScope) // Get this pointer (if it matches T)
						scopeArgs = "this";
				}
				else // ScopeAny struct
				{
					scopeType = "Any"; ;
					if (scope->current == "app" && funcSign != nullptr && funcSign->needScope) // Send global app into GM function
						scopeArgs = "global::_app->id";
					else if (thisPtrValid)
						scopeArgs = "this->id";
				}

				parCpp += "Scope" + scopeType + "(" + scopeArgs + ")";
			}
			else // Send in copy of current Scope variable
				parCpp += "self";

			p++;
		}

		if (varArgs && this->callParameters.size() > 0) // Variable* arguments
		{
			if (p > 0)
				parCpp += ", ";
			parCpp += toExpressionArrayCpp(scope, this->callParameters);
		}
		else // Fixed arguments
		{
			List<Variable*> args = List<Variable*>(); // Get arguments for checking
			if (targetFunc != nullptr)
			{
				for (Variable* var : targetFunc->vars)
					if (var->line == 0)
						args.add(var);

				if (this->callParameters.size() > args.size() && targetFunc->cppSeparateHeader == "")
				{
					Console::writeLine("FATAL ERROR: Invalid argument count for {2} in {0}:{1}", this->func->name, this->line, targetFunc->name);
					Environment::exit(1);
				}
			}

			int arg = 0;
			for (Expression* expr : this->callParameters)
			{
				String exprCpp = expr->toCpp(scope);
				if ((targetFunc != nullptr && arg < static_cast<int>(args.size()) && args[arg]->isReference) ||
					(funcSign != nullptr && funcSign->varCreateRef && arg < static_cast<int>(funcSign->argTypes.size()) && funcSign->argTypes[arg]->isCppVarType())) // Use reference of expression
					exprCpp = "VarType::CreateRef(" + exprCpp + ")";

				parCpp += (p++ > 0 ? ", " : "");

				if (funcSign != nullptr &&
				   funcSign->argTypes[arg]->cppType == DataType::CppType::IntType && !expr->isIntValue() &&
				   expr->resolvedType->cppType != DataType::CppType::IntType) // Cast to int for GM functions
					parCpp += "(IntType)(" + exprCpp + ")";
				else
					parCpp += exprCpp;

				arg++;
			}

			// Add missing arguments as default values
			if (targetFunc != nullptr && targetFunc->args->requiredArgs > static_cast<int>(this->callParameters.size()))
			{
				Console::writeLine("WARNING: Expected {2} parameter(s) to {3}, got {4} in {0}:{1}", this->func->name, this->line, targetFunc->args->requiredArgs, this->name, this->callParameters.size());
				for (int i = this->callParameters.size(); i < targetFunc->args->requiredArgs; i++)
					parCpp += (p++ > 0 ? ", " : "") + args[i]->type->toCppDefaultValue();
			}
		}

		if (parenthesis)
			parCpp += ")";
	}

	cpp += parCpp;

	if (accessorFunc != "")
		cpp += "." + accessorFunc +"(";

	for (ArrayAccessor* acc : this->arrayAccessors) // Accessors
	{
		if (accessorFunc == "")
			cpp += "[";
		cpp += acc->expr->toCpp(scope);
		if (accessorFunc == "")
			cpp += "]";
	}
	if (accessorFunc != "")
		cpp += ")";

	if (this->nextInChain == nullptr && this->addSubOp != Token::Type::Unknown) // ++ or --
		cpp += Token::toCpp(this->addSubOp);

	return cpp;
}

String Accessor::toConditionCpp(ResolveScope* scope, bool parenthesis)
{
	String cpp = toCpp(scope);

	if (this->needLtZero) // Set to true for Int/Real variables
		cpp += " > 0";

	if (parenthesis && this->needLtZero)
		return "(" + cpp + ")";
	else
		return cpp;
}

String Accessor::getNextInChainScope(ResolveScope* scope)
{
	if (Program::objects.containsKey(this->name)) // Object* reference
		return this->name;

	if (this->name == "id" || this->name == "self") // Scope reference
		return scope->currentInChain;

	else if (this->name == "other") // Previous scope reference
		return scope->previous;

	else // Variable* reference
	{
		Function* findVarFunc = (this->previousInChain != nullptr ? nullptr : this->func); // Local variables only visible for first accessor in chain
		Function* funcUpdateScope = (this->previousInChain != nullptr ? nullptr : scope->funcUpdateScope);
		Variable* var = Program::findVariable(scope->currentInChain, this->name, findVarFunc, *scope->location, this->line, funcUpdateScope);

		String varRefId = "";
		if (var != nullptr)
		{
			if (this->arrayAccessors.size() > 0)
			{
				for (DataType::Assignment* ass : var->type->getAssignments()) // Check assignments of variable for containers
				{
					if (ass->rawType >= DataType::Type::Array)
					{
						if (varRefId != "") // Multiple containers found containing references, exit with "any"
							return "any";

						varRefId = ass->containerType->getUniqueReferenceId();
					}
				}
			}
			else
				varRefId = var->type->getUniqueReferenceId();
		}

		return (varRefId == "" ? "any" : varRefId);
	}
}

Function* Accessor::getUserFunction(ResolveScope* scope)
{
	if (Program::objects.containsKey(scope->currentInChain)) // Check instance functions
		if (Program::objects[scope->currentInChain]->instanceFunctions.containsKey(this->name))
			return Program::objects[scope->currentInChain]->instanceFunctions[this->name];

	if (Program::functions.containsKey(this->name)) // Check global functions
		return Program::functions[this->name];

	return nullptr;
}

String Accessor::getAccessorName()
{
	return this->nextInChain == nullptr ? this->name : "";
}

Accessor::ArrayAccessor::ArrayAccessor(DataType::Type type, Expression* expression, bool isRef)
{
	this->type = type;
	this->expr = expression;
	this->isReference = isRef;
}

}
