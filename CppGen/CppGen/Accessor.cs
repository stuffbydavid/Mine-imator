using System;
using System.Collections.Generic;

namespace CppGen
{
	// Variable/Function accessor
	// Accessors can be chained via the member symbol . and have array accessors/function parameters.
	//  varName
	//  instanceVarName.member
	//  funcName(parameters...)
	//  structName.funcName(parameters...)
	//  array[type expression]
	//  array[type expression].member
	public class Accessor : Expression
	{
		public string Name;
		public List<ArrayAccessor> ArrayAccessors;
		public List<Expression> CallParameters;
		public Accessor NextInChain = null;
		public Accessor PreviousInChain = null;
		public Token.Type AddSubOp = Token.Type.Unknown;
		public Expression AssignExpr = null;
		public bool NeedLtZero = false;
		public bool AppToId = true;

		public static bool ResolveUnknownMapTypes = false;
		public static bool ResolveUnknownScope = false;
		public static bool ResolveFunctionReferences = false;
		ResolveScope LastToCppScope = null;

		public class ArrayAccessor
		{
			public DataType.Type Type;
			public Expression Expr;
			public bool IsReference;

			public ArrayAccessor(DataType.Type type, Expression expression, bool isRef)
			{
				Type = type;
				Expr = expression;
				IsReference = isRef;
			}
		}

		public Accessor(string name, List<ArrayAccessor> arrayAccessors, List<Expression> callParameters, Accessor member, Token.Type addSubOp, int line) : base(line)
		{
			Name = name;
			ArrayAccessors = arrayAccessors;
			CallParameters = callParameters;
			NextInChain = member;
			if (NextInChain != null)
			{
				AddSubOp = NextInChain.AddSubOp;
				NextInChain.PreviousInChain = this;
			}
			else
			{
				AddSubOp = addSubOp;
				if (AddSubOp != Token.Type.Unknown)
					MarkAsAssign(this);
			}
			type = Type.Accessor;
		}

		// Marks the accessor as an assignment.
		public void MarkAsAssign(Expression expr)
		{
			AssignExpr = expr;
			NextInChain?.MarkAsAssign(expr);
		}

		// Resolve accessor (when used within an expression or function call statement)
		public override void Resolve(ResolveScope scope)
		{
			if (Program.Enums.ContainsKey(Name)) // Enums are always integer
			{
				ResolvedType = new DataType(DataType.Type.Integer);
				return;
			}

			ResolvedType = new DataType();
			Function userFunction = GetUserFunction(scope);
			DataType.Type accessorType = DataType.Type.Array;
			Variable var = null;

			// Function call
			if (CallParameters != null)
			{
				List<DataType> inputTypes = new List<DataType>();
				foreach (Expression expr in CallParameters) // Resolve expressions into types
				{
					expr.Resolve(scope.OutsideChain()); // use outside scope for instance methods
					inputTypes.Add(new DataType(expr.ResolvedType));
				}

				if (userFunction != null) // User function
				{
					if (scope.Location.Level == 0 && !userFunction.SameScopeFunctions.Contains(Func) && userFunction != Func) // Make this function dependent if outside with()
						userFunction.SameScopeFunctions.Add(Func);
					userFunction.Resolve(new ResolveScope(scope, Func.Name, Line), inputTypes, Func, Line);
					if (scope.Location.Level == 0 && userFunction.HasInstanceVars)
						Func.AssignFunctionScope(userFunction, Func, Line);

					if (Name == "new_obj") // new_obj(objName) returns reference<objName>
					{
						if (CallParameters.Count != 1 || CallParameters[0].type != Type.Accessor)
						{
							Console.WriteLine("FATAL ERROR: Invalid input to new_obj() in {0}:{1}", Func.Name, Line);
							Environment.Exit(1);
						}

						string objName = ((Accessor)CallParameters[0]).Name;
						if (!Program.Objects.ContainsKey(objName))
						{
							Console.WriteLine("FATAL ERROR: Unknown object in new_obj() in {0}:{1}: {2}", Func.Name, Line, objName);
							Environment.Exit(1);
						}
						ResolvedType = new DataType(DataType.Type.Reference, objName);
					}

					else if (Name == "array_add") // array_add(array<typeof arg>, arg/array>
					{
						if (CallParameters.Count < 2 || CallParameters.Count > 3)
						{
							Console.WriteLine("FATAL ERROR: Invalid input to array_add() in {0}:{1}", Func.Name, Line);
							Environment.Exit(1);
						}

						DataType arrType = new DataType();
						int i = 0;
						foreach (DataType inputType in inputTypes)
							if (i++ > 0)
								arrType.Assign(inputType, Func, Line);
						if (arrType.cppType == DataType.CppType.ArrType) // User gave array of values to add, fetch container type
							arrType = arrType.GetFirstAssignment(DataType.Type.Array).ContainerType;
						CallParameters[0].ApplyType(scope, new DataType(DataType.Type.Array, arrType)); // Apply to 1st parameter
						if (CallParameters[0].type == Type.Accessor)
							((Accessor)CallParameters[0]).MarkAsAssign(this);
						ResolvedType = new DataType(userFunction.GetReturnType());
					}

					else if (Name == "array") // array(arg0, arg1...) returns array<typeof args>
					{
						ResolvedType = new DataType(DataType.Type.Array, new DataType());
						foreach (DataType inputType in inputTypes)
							ResolvedType.Assign(new DataType(DataType.Type.Array, inputType), Func, Line);
					}
					else if (Name == "save_id_find") // save_id_find returns unknown object
						ResolvedType = new DataType(DataType.Type.Reference, "");

					else if (Name == "ds_int_map_create") // ds_int_map_create returns IntMap
						ResolvedType = new DataType(DataType.Type.IntMap, new DataType());

					else if (Name == "ds_string_map_create" || Name == "json_load") // ds_string_map_create/json_load returns StringMap
						ResolvedType = new DataType(DataType.Type.StringMap, new DataType());

					else if (Name == "test") // test(bool, arg1, arg2) returns typeof arg1
						ResolvedType = new DataType(inputTypes[1]);

					else
						ResolvedType = new DataType(userFunction.GetReturnType());
				}
				else if (GML.Functions.ContainsKey(Name)) // Built-in function, look up GML spec
				{
					GML.FunctionSignature funcSign = GML.Functions[Name];
					ResolvedType = new DataType(funcSign.ReturnType);

					if (!funcSign.VarArgs && inputTypes.Count != funcSign.ArgTypes.Count) // Check argument match
					{
						Console.WriteLine("FATAL ERROR: Argument count mismatch in {0}:{1}: {2}", Func.Name, Line, Name);
						Environment.Exit(1);
					}

					if (funcSign.NeedScope && scope.Location.Level == 0 && Func.GetScope() == "global") // GML function needs scope, mark global function as any
						Func.AssignScope("any", Func, Line);

					if (Name == "array_create") // array_create(real, [arg]) returns array<typeof arg>
						ResolvedType = new DataType(DataType.Type.Array, inputTypes.Count > 1 ? inputTypes[1] : new DataType());

					else if (Name == "array_length") // array_length returns int, don't apply arguments (since sub-arrays are the same type as array for ArrType)
					{
						ResolvedType = new DataType(DataType.Type.Integer);
						if (CallParameters[0].type == Type.Accessor)
							((Accessor)CallParameters[0]).MarkAsAssign(this);
					}

					else if (Name == "choose" || Name == "max" || Name == "min") // choose/min/max(arg0, arg1...) returns typeof args
					{
						if (Name != "choose")
							ResolvedTypeCpp = DataType.CppType.RealType;
						foreach (DataType inputType in inputTypes)
							ResolvedType.Assign(inputType, Func, Line);
					}
					else if (Name == "ds_list_add") // ds_list_add(list<typeof args>, arg0, arg1...)
					{
						DataType listType = new DataType();
						int i = 0;
						foreach (DataType inputType in inputTypes)
							if (i++ > 0)
								listType.Assign(inputType, Func, Line);
						CallParameters[0].ApplyType(scope, new DataType(DataType.Type.List, listType));
					}
					else if (Name == "ds_map_find_first" || Name == "ds_map_find_next" || Name == "ds_map_find_value") // ds_map_find_x(map<type>, [ key ]) returns type
					{
						DataType.Assignment mapAss = inputTypes[0].GetFirstAssignment(DataType.Type.AnyMap);
						if (mapAss != null)
							ResolvedType.Assign(mapAss.ContainerType, Func, Line);
					}
					else if (Name == "ds_map_add") // ds_map_add(map<typeof arg>, key, arg)
					{
						DataType mapType = new DataType();
						int i = 0;
						foreach (DataType inputType in inputTypes)
							if (i++ > 1)
								mapType.Assign(inputType, Func, Line);
						CallParameters[0].ApplyType(scope, new DataType(DataType.Type.AnyMap, mapType));
					}
					else if (Name == "ds_stack_push") // ds_stack_push(stack<typeof args>, arg0, arg1...)
					{
						DataType stackType = new DataType();
						int i = 0;
						foreach (DataType inputType in inputTypes)
							if (i++ > 0)
								stackType.Assign(inputType, Func, Line);
						CallParameters[0].ApplyType(scope, new DataType(DataType.Type.Stack, stackType));
					}
					else if (Name == "ds_grid_set") // ds_grid_set(grid<typeof arg>, real, real, arg)
						CallParameters[0].ApplyType(scope, new DataType(DataType.Type.Grid, inputTypes[3]));

					else if (Name == "ds_grid_get") // ds_grid_get(grid<type>, x, y) returns type
					{
						DataType.Assignment mapAss = inputTypes[0].GetFirstAssignment(DataType.Type.Grid);
						if (mapAss != null)
							ResolvedType.Assign(mapAss.ContainerType, Func, Line);
					}
					else if (Name == "ds_list_copy" || Name == "ds_map_copy") // ds_x_copy(ds1, typeof ds1)
						CallParameters[0].ApplyType(scope, inputTypes[1]);

					else if (Name == "shader_set_uniform_f" || Name == "shader_set_uniform_i") // shader_set_uniform_f(real, real0, real1...)
					{
						foreach (Expression expr in CallParameters)
							expr.ApplyType(scope, new DataType(DataType.Type.Real));
					}
					// We know the types of all GML function arguments, apply them to the call parameter expressions
					else if (!funcSign.VarArgs)
					{
						int i = 0;
						foreach (Expression expr in CallParameters)
							expr.ApplyType(scope, new DataType(funcSign.ArgTypes[i++]));
					}
				}
				else if (PreviousInChain == null) // Missing function
				{
					Console.WriteLine("FATAL ERROR: Missing function {2} in {0}:{1}", Func.Name, Line, Name);
					Environment.Exit(1);
					return;
				}
			}

			else if (Program.Objects.ContainsKey(Name))
			{
				if (Name == "app") // Pointer to app instance (_app in C++)
					ResolvedType = new DataType(DataType.Type.Reference, "app");

				else // Object reference as integer id
					ResolvedType = new DataType(DataType.Type.Integer);
			}

			else if (userFunction != null) // Function reference
			{
				if (ResolveFunctionReferences) // Resolve after first pass in any scope
				{
					userFunction.AssignScope("any", Func, Line);
					userFunction.Resolve(new ResolveScope(new ResolveScope("any"), Func.Name, Line), null, Func, Line);
				}
				ResolvedType = new DataType(DataType.Type.Integer);
			}

			else if (Program.Shaders.ContainsKey(Name) ||
					 Program.Sprites.ContainsKey(Name)) // Resource reference, treat as integer
				ResolvedType = new DataType(DataType.Type.Integer);

			else if (Name == "id" || Name == "self") // Scope reference
			{
				if (scope.Location.Level == 0 && PreviousInChain == null) // Update function scope if outside with()
					Func.AssignScope(scope.Current, Func, Line, true);
				if (Program.Objects.ContainsKey(scope.CurrentInChain))
					ResolvedType = new DataType(DataType.Type.Reference, scope.CurrentInChain);
			}
			else if (Name == "other") // Previous scope reference
			{
				ResolvedType = new DataType(DataType.Type.Reference, scope.Previous);
				if (scope.Location.Level == 1)
					Func.HasInstanceVars = true;
			}
			else if (Name == "object_index") // Type name
				ResolvedType = new DataType(DataType.Type.Integer);

			else // Variable reference
			{
				if (GML.Variables.ContainsKey(Name)) // Built-in variable
					ResolvedType = new DataType(GML.Variables[Name]);

				else if (GML.Constants.ContainsKey(Name)) // Built-in constant
				{
					bool isInt = (Math.Floor(GML.Constants[Name]) == GML.Constants[Name]); // Integer or Real?
					ResolvedType = new DataType(isInt ? DataType.Type.Integer : DataType.Type.Real);
				}
				else // Project variable
				{
					Function findVarFunc = (PreviousInChain != null ? null : Func); // Local variables only visible for first accessor in chain
					Function funcUpdateScope = (PreviousInChain != null ? null : scope.FuncUpdateScope);
					var = Program.FindVariable(scope.CurrentInChain, Name, findVarFunc, scope.Location, Line, funcUpdateScope);

					if (var == null) // Declare new
						var = Program.DeclareVariable(scope.CurrentInChain, Name, ResolvedType, Func, scope.Location, Line, funcUpdateScope);

					// Try to find container type
					if (ArrayAccessors.Count > 0)
					{
						accessorType = ArrayAccessors[0].Type;
						ResolvedType = new DataType(accessorType, new DataType()); // Get type from accessor value

						if (accessorType == DataType.Type.AnyMap) // Get map type
						{
							ArrayAccessors[0].Expr.Resolve(scope.OutsideChain());
							DataType exprType = ArrayAccessors[0].Expr.ResolvedType;
							if (exprType.cppType == DataType.CppType.StringType) // Accessor is string
								ResolvedType = new DataType(DataType.Type.StringMap, new DataType());
							else if (exprType.cppType == DataType.CppType.IntType) // Accessor is int
								ResolvedType = new DataType(DataType.Type.IntMap, new DataType());
							else if (ResolveUnknownMapTypes) // Variant map
								ResolvedType = new DataType(DataType.Type.Map, new DataType());
						}
						else if (ArrayAccessors[0].Expr.type == Type.Accessor) // Get vector/matrix
						{
							Accessor expr1 = (Accessor)ArrayAccessors[0].Expr;
							if (expr1.Name.StartsWith("PATH_"))
							{
								accessorType = DataType.Type.Array;
								ResolvedType = new DataType(DataType.Type.Variant);
							}
							else if (expr1.Name == "X" || expr1.Name == "Y" || expr1.Name == "Z" || expr1.Name == "W") // Vector
							{
								accessorType = DataType.Type.Vector;
								ResolvedType = new DataType(DataType.Type.Vector, new DataType(DataType.Type.Real));
							}
							else if (expr1.Name == "MAT_X" || expr1.Name == "MAT_Y" || expr1.Name == "MAT_Z") // Matrix
							{
								accessorType = DataType.Type.Matrix;
								ResolvedType = new DataType(DataType.Type.Matrix, new DataType(DataType.Type.Real));
							}
						}
					}

					if (ArrayAccessors.Count > 0) // Convert to array/ds if not container
						var.AssignType(ResolvedType, Func, Line);

					else if (NextInChain != null) // Assign reference
						var.AssignType(new DataType(DataType.Type.Reference, var.Type.GetUniqueReferenceId()), Func, Line);
						
					else if (AddSubOp != Token.Type.Unknown) // Convert to Integer for ++/-- (last in chain only)
					{
						if (ArrayAccessors.Count > 0)
							var.AssignType(new DataType(ArrayAccessors[0].Type, new DataType(DataType.Type.Integer)), Func, Line);
						else
							var.AssignType(new DataType(DataType.Type.Integer), Func, Line);
					}

					ResolvedType = new DataType(var.Type);
				}

				// Has accessors
				if (ArrayAccessors.Count > 0)
				{
					foreach (ArrayAccessor acc in ArrayAccessors) // Resolve accessors
					{
						acc.Expr.Resolve(scope.OutsideChain());
						if (accessorType != DataType.Type.AnyMap) // Array accessors should be integers
							acc.Expr.ApplyType(scope.OutsideChain(), new DataType(DataType.Type.Integer));
					}

					if (var != null && ArrayAccessors[0].IsReference && AssignExpr != null)
						var.MarkReference();

					// Check if Value() is used
					if (ResolvedType.cppType != DataType.CppType.VecType && ResolvedType.cppType != DataType.CppType.MatrixType)
						ResolvedTypeCpp = DataType.CppType.VarType;

					if (ResolvedType.IsContainer()) // Get type from array/ds container
					{
						List<DataType.Assignment> assignments = ResolvedType.Assignments;
						ResolvedType = new DataType(DataType.Type.Unknown); // Reset type

						foreach (DataType.Assignment ass in assignments) // Assign all container types that match the accessors
						{
							if (accessorType == ass.RawType ||
								(accessorType == DataType.Type.AnyMap && DataType.IsRawTypeMap(ass.RawType)) ||
								(accessorType == DataType.Type.Array && DataType.IsRawTypeArray(ass.RawType)))
								ResolvedType.Assign(new DataType(ass.ContainerType), Func, Line);
						}

						if (ResolvedType.IsUnknown()) // ds[unknown] -> variant
							ResolvedType = new DataType(DataType.Type.Variant);

					}
					else
						Program.AddSyntaxError("Used [] on non-container type " + Name + " in " + Func.Name + ":" + Line);
				}
			}

			if (NextInChain != null) // Resolve next in chain recursively
			{
				string nextInChainScope = GetNextInChainScope(scope);
				if (nextInChainScope == "any")
				{
					UnknownScopes++;
					ResolvedType = new DataType();
					if (!ResolveUnknownScope)
						return;
				}

				NextInChain.Resolve(scope.NextInChain(nextInChainScope));
				ResolvedType = NextInChain.ResolvedType;
				ResolvedTypeCpp = NextInChain.ResolvedTypeCpp;
			}

			if (AssignExpr != null)
				AssignExpr.AssignedTo = var;
		}

		// Apply a type to the accessor when assigned
		public override bool ApplyType(ResolveScope scope, DataType type)
		{
			if (Program.Enums.ContainsKey(Name)) // Skip enums
				return false;
			
			bool changed = false;
			if (NextInChain != null)  // Apply to next in chain only
			{
				string nextInChainScope = GetNextInChainScope(scope);
				if (nextInChainScope == "any")
				{
					UnknownScopes++;
					if (!ResolveUnknownScope)
						return false;
				}

				return NextInChain.ApplyType(scope.NextInChain(nextInChainScope), type);
			}

			if (ArrayAccessors.Count > 0) // Convert to container type
				type = new DataType(ArrayAccessors[0].Type, type);

			// Function call
			if (CallParameters != null)
			{
				Function userFunction = GetUserFunction(scope);
				if (userFunction != null) // Update return type
					userFunction.AssignReturnType(type, Func, Line);
			}
			else if (!GML.Constants.ContainsKey(Name) && !GML.Variables.ContainsKey(Name) &&
					 !Program.Objects.ContainsKey(Name) && !Program.Macros.ContainsKey(Name)) // User variable
			{
				Function findVarFunc = (PreviousInChain != null ? null : Func); // Local variables only visible for first accessor in chain
				Function funcUpdateScope = (PreviousInChain != null ? null : scope.FuncUpdateScope);
				Variable var = Program.FindVariable(scope.CurrentInChain, Name, findVarFunc, scope.Location, Line, funcUpdateScope);

				if (var != null) // Apply type to variable
					changed = var.AssignType(type, Func, Line);
				else // Declare new
					var = Program.DeclareVariable(scope.CurrentInChain, Name, type, Func, scope.Location, Line, funcUpdateScope);

				if (AssignExpr != null)
					AssignExpr.AssignedTo = var;
			}

			return changed;
		}

		// Write the C++ code of the accessor.
		public override string ToCpp(ResolveScope scope)
		{
			string cpp = "";
			if (Program.Enums.ContainsKey(Name)) // Enum (with prefix)
				return NameToCpp(Name) + "_" + NameToCpp(NextInChain.Name);

			// external_call(name, [args...])
			if (Name == "external_call" && CallParameters != null && CallParameters.Count > 0)
			{
				Accessor callAcc = (Accessor)CallParameters[0];
				if (!Program.ExternalFunctions.ContainsKey(callAcc.Name))
				{
					Program.SyntaxErrors.Add("external_call on unknown function " + callAcc.Name + " in " + Func.Name + ":" + Line);
					return "";
				}

				string callCpp = callAcc.Name + "(";
				for (int i = 1; i < CallParameters.Count; i++)
					callCpp += (i > 1 ? ", " : "") + CallParameters[i].ToCpp(scope);
				callCpp += ")";
				return callCpp;
			}

			// ord("X") -> (int)'X'
			if (Name == "ord" && CallParameters.Count > 0 && CallParameters[0].type == Type.Value)
			{
				ExpressionValue value = (ExpressionValue)CallParameters[0];
				if (value.ValueType == Token.Type.String)
					return "(IntType)'" + value.Value + "'";
			}

			// current_time -> current_time()
			if (Name == "current_time")
				return "current_time()";

			// new_obj(objName) -> (new objName)->id
			if (Name == "new_obj")
				return "(new " + ((Accessor)CallParameters[0]).Name + ")->id";

			// test(bool, val1, val2) -> ((bool) ? val1 : val2)
			if (Name == "test")
				return "(" + ToTernaryCpp(scope, CallParameters[0], CallParameters[1], CallParameters[2]) + ")";

			if (Program.Sprites.ContainsKey(Name) ||
				Program.Shaders.ContainsKey(Name)) // Convert resource names to integer id
				return "ID_" + Name;

			bool funcInstance = false;
			if (Name != "app" && Program.Objects.ContainsKey(Name)) // Objects to integer id (except app and new expresisons)
			{
				if (Program.Objects[Name].IsStruct)
					funcInstance = true;
				else
					return "ID_" + Name;
			}

			if (LastToCppScope == null && NextInChain != null) // Generate C++ in chain from last to first on first call
			{
				LastToCppScope = scope; // Save scope
				string nextInChainScope = GetNextInChainScope(scope);
				cpp = NextInChain.ToCpp(scope.NextInChain(nextInChainScope));
				NeedLtZero = NextInChain.NeedLtZero;
				WrittenType = NextInChain.WrittenType;
				return cpp;
			}

			if (LastToCppScope != null) // Restore scope
				scope = LastToCppScope;

			bool thisPtrValid = (scope.Location.Level == 0 && Func.StructObject != null); // In struct method outside any with()

			if (Name == "app") // app instance id
				return AppToId ? "global::_app->id" : "ID_app";

			if (Name == "other") // other instance id
				return "self.otherId";

			if (Name == "id" || Name == "self" || Name == "object_index") // id/object_index
			{
				if (PreviousInChain != null)
				{
					if (Name == "object_index") // Get assetId from chain
						return "Obj(" + PreviousInChain.ToCpp(scope) + ")->subAssetId";
					else
						return PreviousInChain.ToCpp(scope); // Previous chain should give an int for the id
				}
				else
				{
					string mem = (Name == "object_index" ? "subAssetId" : "id");
					if (thisPtrValid)
						return mem;
					else if (scope.Current == "app")
						return "global::_app->" + mem;
					else
						return "self->" + mem;
				}
			}

			Object scopeObj = Program.Objects.ContainsKey(scope.CurrentInChain) ? Program.Objects[scope.CurrentInChain] : null;
			Function func = null;
			GML.FunctionSignature funcSign = null;
			bool varArgs = false;
			string parCpp = "";
			bool parenthesis = true;
			string accessorFunc = "";

			if (GML.Constants.ContainsKey(Name) || GML.Keywords.Contains(Name) || Name == "argument" || Name == "argument_count") // GML Keyword
				cpp += NameToCpp(Name);
			
			else if (GML.Variables.ContainsKey(Name)) // Global GML variable
			{
				cpp += "gmlGlobal::" + NameToCpp(Name);
				if (GML.Variables[Name].GetFirstAssignment().RawType == DataType.Type.Map)
					cpp = "DsMap(" + cpp + ")";
			}

			else if (Name != "argument" && Name != "argument_count" && Name.StartsWith("argument")) // argument0..15
			{
				int argNum = Convert.ToInt32(Name.Replace("argument", ""));
				if (Func.Vars.Count > argNum && Func.Vars[argNum].Line == 0)
					cpp += Func.Vars[argNum].Name;
				else
					Program.AddSyntaxError("Invalid " + Name + " in " + Func.Name + ":" + Line);
			}
			else if (GML.Functions.ContainsKey(Name)) // GML function
			{
				if (Name == "ds_map_create" && AssignedTo != null) // Convert map creation to specific map type
				{
					DataType.Type varMapType = AssignedTo.Type.GetMapType();
					if (varMapType == DataType.Type.IntMap)
						cpp += "ds_int_map_create";
					else if (varMapType == DataType.Type.StringMap)
						cpp += "ds_string_map_create";
					else
						cpp += Name;
				}
				else
					cpp += NameToCpp(Name);

				GML.FunctionSignature sign = GML.Functions[Name];
				funcSign = GML.Functions[Name];
				varArgs = funcSign.VarArgs;
			}

			else if (Program.Functions.ContainsKey(Name)) // User script
			{
				if (CallParameters == null) // Script name, convert to integer id
					return "ID_" + Name;

				func = Program.Functions[Name];
				varArgs = func.VarArgs;

				if (Name == "array") // array(args) -> ArrType::From({ args })
				{
					if (CallParameters.Count == 0) // array() -> ArrType()
						return "ArrType()";
					cpp += "ArrType::From";
				}
				else
					cpp += NameToCpp(Name);
			}

			else if (scopeObj != null && scopeObj.InstanceFunctions.ContainsKey(Name)) // Instance function
			{
				func = scopeObj.InstanceFunctions[Name];
				if (PreviousInChain != null && PreviousInChain.Name != "self") // Ptr from chain
					cpp += "ObjType(" + scopeObj.Name + ", " + PreviousInChain.ToCpp(scope) + ")->";
				cpp += NameToCpp(Name);
				funcInstance = true;
			}

			else if (CallParameters != null) // Instance function in unknown scope
			{
				bool foundFuncAnywhere = false;
				foreach (Object obj in Program.Objects.Values)
				{
					foreach (Function instFunc in obj.InstanceFunctions.Values)
					{
						if (instFunc.Name == Name)
						{
							foundFuncAnywhere = true;
							break;
						}
					}
				}
				if (!foundFuncAnywhere || PreviousInChain == null)
					Console.WriteLine("FATAL ERROR: Unknown function {2} in {0}:{1}", Func.Name, Line, Name);

				// Get id from chain and feed into idFunc macro
				cpp += "idFunc(" + PreviousInChain.ToCpp(scope) + ", " + Name + ")";
				varArgs = true;
				if (CallParameters.Count == 0)
					parCpp = "(ArrType())";

			}
			else // Variable (global, local, instance or unknown)
			{
				Function findVarFunc = (PreviousInChain != null ? null : Func); // Local variables only visible for first accessor in chain
				Variable var = Program.FindVariable(scope.CurrentInChain, Name, findVarFunc, scope.Location, Line, null, false);
				string macroName = "";

				if (var != null)
				{
					WrittenType = var.Type;
					if (var.Scope == "app") // App
						cpp += "global::_app->" + NameToCpp(Name);

					else if (scopeObj != null && PreviousInChain != null && PreviousInChain.Name != "app" && PreviousInChain.Name != "self") // Ptr from chain
						cpp += "ObjType(" + scopeObj.Name + ", " + PreviousInChain.ToCpp(scope) + ")->" + NameToCpp(Name);

					else if (var.Scope == "global") // Global/Macro
					{
						if (!Program.Macros.ContainsKey(Name))
							cpp += "global::";
						cpp += NameToCpp(Name);
					}

					else if (var.Scope == Func.Name || (thisPtrValid && var.Scope == Func.StructObject.Name)) // Instance (with same scope)
					{
						cpp += NameToCpp(Name);
						if (var.IsReference) // Get array/vector/matrix reference
						{
							if (AssignExpr != null) // arr[@i] = x
								cpp += ".Arr()"; // var.Arr()[i] = x
							else if (ArrayAccessors.Count == 1) // arr[@i] = value
								accessorFunc = "Ref"; // arr.Ref(i) = value
						}
					}
					else // Scope variable
						cpp += "self->" + NameToCpp(Name);
				}
				else // Unresolved scope, use member macro
				{
					bool foundVarAnywhere = Program.UnknownScopeVars.ContainsKey(Name);
					foreach (Object obj in Program.Objects.Values)
					{
						if (obj.InstanceVars.ContainsKey(Name))
						{
							WrittenType.Assign(obj.InstanceVars[Name].Type, null, 0);
							foundVarAnywhere = true;
						}
					}
					if (!foundVarAnywhere)
						Console.WriteLine("WARNING: Unknown variable {2} in {0}:{1}", Func.Name, Line, Name);
					macroName = WrittenType.ToCppMemberMacro();
				}

				// Check if > 0 is needed in conditions
				if (!Program.Macros.ContainsKey(Name))
					if (WrittenType.cppType == DataType.CppType.IntType ||
						WrittenType.cppType == DataType.CppType.RealType ||
						WrittenType.cppType == DataType.CppType.VarType)
						NeedLtZero = true;

				if (macroName != "") // Create macro
				{
					if (PreviousInChain != null) // Id from chain
						cpp += "id" + macroName + "(" + PreviousInChain.ToCpp(scope) + ", " + NameToCpp(Name) + ")";
					else // Id from Scope variable
						cpp += "s" + macroName + "(" + NameToCpp(Name) + ")";
				}

				if (ArrayAccessors.Count == 1)
				{
					// Prefer Real() for vector/matrix operations
					if (WrittenType.cppType == DataType.CppType.VecType || WrittenType.cppType == DataType.CppType.MatrixType)
						accessorFunc = "Real";
					
					else // Data structure lookup
					{
						DataType.Type dsType = DataType.Type.Unknown;
						if (var != null) // Look for ds in assignments
							foreach (DataType.Assignment ass in var.Type.Assignments)
								if (ass.RawType >= DataType.Type.List)
									dsType = ass.RawType;

						if (ArrayAccessors[0].Type >= DataType.Type.Array) // Look for ds accessor
							dsType = ArrayAccessors[0].Type;

						if (dsType != DataType.Type.Unknown)
						{
							// Wrap in DsX macro
							if (dsType == DataType.Type.List)
								cpp = "DsList(" + cpp + ")";
							else if (dsType == DataType.Type.AnyMap)
								cpp = "DsMap(" + cpp + ")";
							else if (dsType == DataType.Type.Grid)
								cpp = "DsGrid(" + cpp + ")";
						}

						// Prefer .Value(index/key) const for read-only
						if (AssignExpr == null)
							accessorFunc = "Value";
					}
				}
			}

			if (CallParameters != null && parCpp == "") // Parameters
			{
				int p = 0;
				if (parenthesis)
					parCpp += "(";

				string funcScope = "global";
				if (func != null)
					funcScope = func.GetScope();
				else if (funcSign != null && funcSign.NeedScope)
					funcScope = "any";

				if (funcScope != "global" && funcScope != "app" && !funcInstance) // Send in scope for non-global/non-instance
				{
					if (thisPtrValid || scope.Current != funcScope) // Make new scope
					{
						string scopeType, scopeArgs = "self";

						if (funcScope != "any") // Scope<T> struct
						{
							scopeType = "<" + funcScope + ">";
							if (thisPtrValid && Func.StructObject.Name == funcScope) // Get this pointer (if it matches T)
								scopeArgs = "this";
						}
						else // ScopeAny struct
						{
							scopeType = "Any"; ;
							if (scope.Current == "app" && funcSign != null && funcSign.NeedScope) // Send global app into GM function
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

				if (varArgs && CallParameters.Count > 0) // Variable arguments
				{
					if (p > 0)
						parCpp += ", ";
					parCpp += ToExpressionArrayCpp(scope, CallParameters);
				}
				else // Fixed arguments
				{
					List<Variable> args = new List<Variable>(); // Get arguments for checking
					if (func != null)
					{
						foreach (Variable var in func.Vars)
							if (var.Line == 0)
								args.Add(var);

						if (CallParameters.Count > args.Count && func.CppSeparateHeader == "")
						{
							Console.WriteLine("FATAL ERROR: Invalid argument count for {2} in {0}:{1}", Func.Name, Line, func.Name);
							Environment.Exit(1);
						}
					}

					int arg = 0;
					foreach (Expression expr in CallParameters)
					{
						string exprCpp = expr.ToCpp(scope);
						if ((func != null && arg < args.Count && args[arg].IsReference) ||
							(funcSign != null && funcSign.VarCreateRef && arg < funcSign.ArgTypes.Count && funcSign.ArgTypes[arg].IsCppVarType())) // Use reference of expression
							exprCpp = "VarType::CreateRef(" + exprCpp + ")";

						parCpp += (p++ > 0 ? ", " : "");

						if (funcSign != null &&
						   funcSign.ArgTypes[arg].cppType == DataType.CppType.IntType && !expr.IsIntValue() &&
						   expr.ResolvedType.cppType != DataType.CppType.IntType) // Cast to int for GM functions
							parCpp += "(IntType)(" + exprCpp + ")";
						else
							parCpp += exprCpp;

						arg++;
					}

					// Add missing arguments as default values
					if (func != null && func.Args.RequiredArgs > CallParameters.Count)
					{
						Console.WriteLine("WARNING: Expected {2} parameter(s) to {3}, got {4} in {0}:{1}", Func.Name, Line, func.Args.RequiredArgs, Name, CallParameters.Count);
						for (int i = CallParameters.Count; i < func.Args.RequiredArgs; i++)
							parCpp += (p++ > 0 ? ", " : "") + args[i].Type.ToCppDefaultValue();
					}
				}

				if (parenthesis)
					parCpp += ")";
			}

			cpp += parCpp;

			if (accessorFunc != "")
				cpp += "." + accessorFunc +"(";

			foreach (ArrayAccessor acc in ArrayAccessors) // Accessors
			{
				if (accessorFunc == "")
					cpp += "[";
				cpp += acc.Expr.ToCpp(scope);
				if (accessorFunc == "")
					cpp += "]";
			}
			if (accessorFunc != "")
				cpp += ")";

			if (NextInChain == null && AddSubOp != Token.Type.Unknown) // ++ or --
				cpp += Token.ToCpp(AddSubOp);

			return cpp;
		}

		// Wraps an accessor in (x > 0) since C++ conditions are true for negative values.
		public override string ToConditionCpp(ResolveScope scope, bool parenthesis)
		{
			string cpp = ToCpp(scope);

			if (NeedLtZero) // Set to true for Int/Real variables
				cpp += " > 0";

			if (parenthesis && NeedLtZero)
				return "(" + cpp + ")";
			else
				return cpp;
		}

		// Find the scope of the accessor next in the chain.
		string GetNextInChainScope(ResolveScope scope)
		{
			if (Program.Objects.ContainsKey(Name)) // Object reference
				return Name;

			if (Name == "id" || Name == "self") // Scope reference
				return scope.CurrentInChain;

			else if (Name == "other") // Previous scope reference
				return scope.Previous;

			else // Variable reference
			{
				Function findVarFunc = (PreviousInChain != null ? null : Func); // Local variables only visible for first accessor in chain
				Function funcUpdateScope = (PreviousInChain != null ? null : scope.FuncUpdateScope);
				Variable var = Program.FindVariable(scope.CurrentInChain, Name, findVarFunc, scope.Location, Line, funcUpdateScope);

				string varRefId = "";
				if (var != null)
				{
					if (ArrayAccessors.Count > 0)
					{
						foreach (DataType.Assignment ass in var.Type.GetAssignments()) // Check assignments of variable for containers
						{
							if (ass.RawType >= DataType.Type.Array)
							{
								if (varRefId != "") // Multiple containers found containing references, exit with "any"
									return "any";

								varRefId = ass.ContainerType.GetUniqueReferenceId();
							}
						}
					}
					else
						varRefId = var.Type.GetUniqueReferenceId();
				}

				return (varRefId == "" ? "any" : varRefId);
			}
		}

		// Finds an user function with the given name in a scope, or null if none exists.
		Function GetUserFunction(ResolveScope scope)
		{
			if (Program.Objects.ContainsKey(scope.CurrentInChain)) // Check instance functions
				if (Program.Objects[scope.CurrentInChain].InstanceFunctions.ContainsKey(Name))
					return Program.Objects[scope.CurrentInChain].InstanceFunctions[Name];
			
			if (Program.Functions.ContainsKey(Name)) // Check global functions
				return Program.Functions[Name];

			return null;
		}

		public override string GetAccessorName()
		{
			return NextInChain == null ? Name : "";
		}
	}
}
