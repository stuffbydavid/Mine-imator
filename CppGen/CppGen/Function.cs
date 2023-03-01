using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace CppGen
{
	// Function
	public class Function
	{
		public string Name = "";
		public string Gml;
		public List<Token> Tokens = new List<Token>();
		public DeclarationList Args;
		public bool VarArgs = false;
		public List<Variable> Vars = new List<Variable>();
		public List<string> VarArgsRequiredNames = new List<string>();
		public StatementList Statements;
		public Object StructObject = null;
		public List<string> CppLinesBegin = new List<string>();
		public List<string> CppLinesEnd = new List<string>();
		public bool IsCppSeparate = false;
		public string CppSeparateHeader = "";
		public DataType CppSeparateReturnType = null;

		public List<Variable> InstanceVarDecls = new List<Variable>();
		public List<ScopeAssignment> ScopeAssignments = new List<ScopeAssignment>();
		public List<string> ScopesTraversed = new List<string>();
		public List<Function> SameScopeFunctions = new List<Function>();
		public DataType ReturnType = new DataType();
		public ReturnStatement Return = null;
		public bool EndsWithReturnStatement = false;
		public bool HasInstanceVars = false;
		public bool IsUnused = true;
		public bool IsTraversed = false;
		public bool IsConstructor = false;
		public bool IsDestructor = false;

		public static bool EnableAssignScope = false;
		public static Function CurrentParseFunction = null;
		public static int CurrentParseLine = 0;

		private int TokenIndex = 0;
		private Token.Type LastPeeked;
		private Token CurrentToken = null;
		private bool ImplWritten = false;

		public Function(string name, string gml = "", bool isCppSeparate = false, string cppSeparateHeader = "")
		{
			Name = name;
			Gml = gml;
			IsCppSeparate = isCppSeparate;

			if (IsCppSeparate)
			{
				CppSeparateHeader = cppSeparateHeader;

				string[] words = CppSeparateHeader.Substring(0, CppSeparateHeader.IndexOf("(")).Split(" ");
				string type = "";
				for (int i = 0; i < words.Length - 1; i++)
					type += (i > 0 ? " " : "") + words[i];
				CppSeparateReturnType = new DataType(type);

				VarArgs = CppSeparateHeader.Contains("VarArgs");
			}

			if (Gml == "")
			{
				Statements = new StatementList(1);
				Statements.Func = this;
			}
		}

		// Assigns a scope to a function whenever an instance variable is accessed in a with() scope, or another function with an instance scope is called.
		public class ScopeAssignment
		{
			public string Scope;
			public Function Func;
			public int Line;

			public ScopeAssignment(string scope, Function func, int line)
			{
				Scope = scope;
				Func = func;
				Line = line;
			}
		}

		// Returns the scope of the function, or "any" when executed in multiple scopes.
		public string GetScope()
		{
			if (StructObject != null)
				return StructObject.Name;


			if (ScopeAssignments.Count == 0)
				return HasInstanceVars ? "any" : "global";

			if (ScopeAssignments.Count > 1 || DataType.AllVarType)
				return "any";

			return ScopeAssignments[0].Scope;
		}

		// Assigns a scope to the function when an instance variable is found.
		public bool AssignScope(string scope, Function func, int line, bool foundInstanceVar = false)
		{
			if (!EnableAssignScope || StructObject != null)
				return false;

			if (foundInstanceVar)
				HasInstanceVars = true;

			if (ScopesTraversed.Contains(scope)) // Avoid infinite recursion
				return false;
			ScopesTraversed.Add(scope);

			// Assign same scope to all other function that has called this outside of a with()
			foreach (Function depFunc in SameScopeFunctions)
				depFunc.AssignScope(scope, func, line, HasInstanceVars);

			foreach (ScopeAssignment ass in ScopeAssignments)
				if (ass.Scope == scope)
					return false;

			ScopeAssignments.Add(new ScopeAssignment(scope, func, line));
			return true;
		}

		// Assigns the scope of another function.
		public void AssignFunctionScope(Function otherFunc, Function func, int line)
		{
			if (!EnableAssignScope)
				return;

			foreach (ScopeAssignment ass in otherFunc.ScopeAssignments)
				AssignScope(ass.Scope, func, line, true);
		}

		// Writes the C++ arguments of the function.
		public void WriteCppArguments(DeclarationList.WriteFormat format)
		{
			string scope = GetScope();
			if (scope != "global" && scope != "app" && StructObject == null) // Include scope variable in non-global functions
			{
				if (scope == "any")
					CodeWriter.Write("ScopeAny self");
				else
					CodeWriter.Write("Scope<" + scope + "> self");
				if (VarArgs || Args.Declarations.Count > 0)
					CodeWriter.Write(", ");
			}

			if (VarArgs) // VarArgs type
				CodeWriter.Write("VarArgs argument" + (format == DeclarationList.WriteFormat.ArgsHeader ? " = VarArgs()": ""));
			else if (Args != null && Args.Declarations.Count > 0) // Declarations
				Args.WriteCpp(new ResolveScope("global"), format);
		}

		// Write the C++ header of the function.
		public void WriteCppHeader()
		{
			if (!IsCppSeparate)
			{
				// Name
				if (IsConstructor)
					CodeWriter.Write(StructObject.Name);
				else if (IsDestructor)
					CodeWriter.Write("~" + StructObject.Name);
				else
					CodeWriter.Write(GetReturnType().ToCpp() + " " + CodeObject.NameToCpp(Name));

				CodeWriter.Write("(");
				WriteCppArguments(DeclarationList.WriteFormat.ArgsHeader);
				CodeWriter.WriteLine(");");
			}
			else
				CodeWriter.WriteLine(CppSeparateHeader + ";");
		}

		// Write the C++ implementation of the function. Returns whether anything was written.
		public bool WriteCppImplementation()
		{
			if (ImplWritten)
				return false;
			ImplWritten = true;

			// Name
			if (IsConstructor)
				CodeWriter.Write(StructObject.Name + "::" + StructObject.Name);
			else if (IsDestructor)
				CodeWriter.Write(StructObject.Name + "::~" + StructObject.Name);
			else
			{
				CodeWriter.Write(ReturnType.ToCpp() + " ");
				if (StructObject != null)
					CodeWriter.Write(StructObject.Name + "::");
				CodeWriter.Write(CodeObject.NameToCpp(Name));
			}

			CodeWriter.Write("(");
			WriteCppArguments(DeclarationList.WriteFormat.ArgsImpl);
			CodeWriter.WriteLine(")", 1);
			if (IsConstructor)
				CodeWriter.WriteLine(": Object(\"" + StructObject.Name + "\", ID_" + StructObject.Name + ")");

			if (VarArgs) // Variable arguments
			{
				CppLinesBegin.Add("IntType argument_count = argument.Size();"); // Declare argument_count

				if (VarArgsRequiredNames.Count > 0) // Declare required arguments
				{
					for (int arg = 0; arg < Args.Declarations.Count; arg++)
					{
						Variable var = Program.FindVariable(Name, Args.Declarations[arg].Name, this, new Statement.Location(), 0);
						if (VarArgsRequiredNames.Contains(var.Name))
							CppLinesBegin.Add(var.Type.ToCpp() + " " + CodeObject.NameToCpp(var.Name) + " = argument[" + arg + "];");
					}
				}
			}

			if (!IsConstructor && !IsDestructor && !EndsWithReturnStatement && ReturnType.cppType != DataType.CppType.Void)
				CppLinesEnd.Add("return " + ReturnType.ToCppDefaultValue() + ";");

			Statements.WriteCpp(new ResolveScope(GetScope()));
			CodeWriter.WriteLine("", -1);
			CodeWriter.WriteLine();
			return true;
		}

		// Returns a C++ lambda for executing the function using script_execute or the idFunc macro.
		public string ToExecuteCpp()
		{
			string cpp = "{ ";
			int a = 0;

			// Return
			bool isVoid = (GetReturnType().cppType == DataType.CppType.Void);
			if (!isVoid)
				cpp += "return ";

			cpp += Name + "(";

			// Create scope with ids
			string scope = GetScope();
			if (StructObject == null && scope != "global" && scope != "app")
			{
				cpp += "Scope";
				if (scope == "any")
					cpp += "Any";
				else
					cpp += "<" + scope + ">";
				cpp += "(s, o)";
				a++;
			}

			// Arguments
			if (VarArgs)
				cpp += (a > 0 ? ", " : "") + "a";
			else
			{
				int p = 0;
				foreach (Declaration decl in Args.Declarations)
				{
					cpp += (a > 0 ? ", " : "");
					if (decl.Expr != null) // Optional
						cpp += "a.Size() > " + p + " ? a[" + p + "] : VarType(" + decl.Expr.ToCpp(new ResolveScope("global")) + ")";
					else // Required
						cpp += "a[" + p + "]";
					a++;
					p++;
				}
			}
			cpp += "); ";

			// Return default
			if (isVoid)
				cpp += "return VarType(); ";

			cpp += "}";
			return cpp;
		}

		// Returns a debug string of the function and its variables
		public string ToDebugString(string tabs = "")
		{
			string str = tabs + "[" + GetScope() + "] " + Name;
			if (Args != null)
				str += " - " + Args.RequiredArgs + " required arguments";

			str += "\n";
			tabs += "\t";
			str += tabs + "Scope assignments:\n";
			tabs += "\t";
			foreach (ScopeAssignment ass in ScopeAssignments)
			{
				str += tabs + ass.Scope;
				if (ass.Func != null)
					str += " in " + ass.Func.Name + ":" + ass.Line;
				str += "\n";
			}
			tabs = tabs.Remove(1, 1);
			if (HasInstanceVars)
				str += tabs + "Contains instance variables\n";
			str += tabs + "Returns " + GetReturnType().ToCpp() + "\n";
			if (ReturnType.Assignments.Count > 0)
				str += ReturnType.GetAssignmentsString(tabs + "    ");
			int i = 0;
			if (VarArgs)
				str += tabs + "VarArgs\n";
			foreach (Variable var in Vars)
			{
				if (var.Line == 0)
					str += tabs + "Argument " + (i++) + ": ";
				else
					str += tabs + "Line " + var.Line + ": ";
				str += var.Type.ToCpp() + " " + var.Name ;
				if (var.Location.Path.Count > 0)
					str += " " + var.Location.ToString();
				str += "\n";
				str += var.Type.GetAssignmentsString(tabs + "\t");
			}
			return str;
		}

		// Resolves the variables in the function, recursively calling other functions as they appear.
		public void Resolve(ResolveScope scope, List<DataType> inputPars = null, Function func = null, int line = 0)
		{
			if (StructObject != null) // Switch scope to StructObject
				scope = new ResolveScope(StructObject.Name, scope.CurrentInChain, scope.Calls);
			scope.FuncUpdateScope = this;
			scope.Location = new Statement.Location();

			// Resolve arguments with given input
			bool argsChanged = false, scopeChanged = false;
			if (Args != null)
				argsChanged = Args.Resolve(scope, Name, inputPars) && !scope.IsCalled(Name);

			if (IsTraversed && HasInstanceVars) // Assign new scope 
				scopeChanged = AssignScope(scope.Current, func, line);

			// Traverse only if first time or scope/arguments changed.
			if (IsTraversed && !scopeChanged && !argsChanged)
				return;

			IsTraversed = true;
			IsUnused = false;

			// Resolve statements
			Statements.Resolve(scope);

			// Check return
			if (Return != null && Return.location != null && Return.location.Path.Count > 1)
				EndsWithReturnStatement = false;
		}

		// Sets the return type of the function, if it changes then all functions dependent on this one are marked unresolved.
		public void AssignReturnType(DataType type, Function func, int line)
		{
			if (CppSeparateReturnType == null)
				ReturnType.Assign(type, func, line);
		}

		// Gets the return type of the function.
		public DataType GetReturnType()
		{
			if (CppSeparateReturnType != null)
				return CppSeparateReturnType;
			return ReturnType;
		}

		// Parses the tokens and creates a statement list of the function.
		public void ParseTokens()
		{
			if (Gml == "")
				return;

			CurrentParseFunction = this;
			CurrentParseLine = 0;

			// Signature with arguments
			NextToken(Token.Type.ID, "function");
			NextToken(Token.Type.ID, Name);
			NextToken(Token.Type.LeftPar);
			Args = ParseDeclarations(true);
			NextToken(Token.Type.RightPar);

			// Check if struct, make this constructor of a new object
			if (PeekToken() == Token.Type.ID && CurrentToken.Value == "constructor")
			{
				StructObject = new Object(Name, true);
				StructObject.SetConstructor(this);
				ReturnType = new DataType(DataType.Type.Reference, Name);
				Program.Objects.Add(Name, StructObject);
				NextToken(Token.Type.ID);
			}

			// Statement list in brackets
			NextToken(Token.Type.LeftBrace);
			Statements = ParseStatementList();
			NextToken(Token.Type.RightBrace);

			// No return found, set to void function
			if (StructObject == null && Return == null)
				ReturnType = new DataType(DataType.Type.Void);
			else if (Return != null)
				EndsWithReturnStatement = (Statements.Statements[Statements.Statements.Count - 1].type == Statement.Type.Return);
		}

		// Returns the current token type.
		Token.Type PeekToken()
		{
			if (TokenIndex >= Tokens.Count)
			{
				Console.WriteLine("FATAL ERROR in {0}:", Name);
				Console.WriteLine("  Unexpected end of function.");
				Environment.Exit(1);
			}

			LastPeeked = CurrentToken.type;
			return LastPeeked;
		}

		// Advances to the next token.
		Token NextToken(Token.Type expectedType, string expectedValue = "")
		{
			Token token = Tokens[TokenIndex];
			if (token.type != expectedType || (expectedValue != "" && token.Value != expectedValue))
			{
				Console.WriteLine("FATAL ERROR in {0}:", Name);
				if (token.type == Token.Type.ID)
					Console.WriteLine("  Unexpected \"{0}\" at line {1}, {2}", token.Value, token.Line, token.FileOffset - token.LineOffset);
				else
					Console.WriteLine("  Unexpected {0} token at line {1}, {2}", token.type, token.Line, token.FileOffset - token.LineOffset);

				if (expectedType != Token.Type.Error)
					Console.WriteLine("  Expected token was {0}", expectedType);
				Environment.Exit(1);
			}
			TokenIndex++;
			if (TokenIndex < Tokens.Count)
			{
				CurrentToken = Tokens[TokenIndex];
				CurrentParseLine = CurrentToken.Line;
			}
			else
				CurrentToken = null;
			return token;
		}

		StatementList ParseStatementList()
		{
			StatementList sl = new StatementList(CurrentParseLine);
			while (true)
			{
				if (CurrentToken.Value == "case" || CurrentToken.Value == "default" ||
					CurrentToken.Value == "else" || CurrentToken.Value == "until") // End of list
					return sl;

				int line = CurrentParseLine;
				switch (PeekToken())
				{
					case Token.Type.Terminator: // ;
					{
						NextToken(Token.Type.Terminator); // Ignore
						break;
					}

					case Token.Type.HashTag: // #macro
					{
						NextToken(Token.Type.HashTag);
						NextToken(Token.Type.ID, "macro");
						string macroName = NextToken(Token.Type.ID).Value;
						sl.AddStatement(new MacroStatement(macroName, ParseExpr(), line));
						break;
					}

					case Token.Type.CppOnly: // Custom C++
					{
						string cpp = CurrentToken.Value;
						NextToken(Token.Type.CppOnly);
						sl.AddStatement(new CustomCppStatement(cpp, line));
						break;
					}

					case Token.Type.ID: // name
					case Token.Type.LeftPar: // (
					case Token.Type.LeftBrace: // {
					{
						Statement stmt = ParseStatement();
						if (stmt != null)
							sl.AddStatement(stmt);
						break;
					}

					default:
						return sl;
				}
			}
		}

		Statement ParseStatement()
		{
			int line = CurrentParseLine;
			switch (PeekToken())
			{
				case Token.Type.ID:
				{
					switch (CurrentToken.Value)
					{
						case "enums": // Skip enums() call
						{
							ParseAccessor();
							return null;
						}

						case "var":
						case "globalvar": // var/globalvar name [ = expr], ...
						{
							Token declToken = NextToken(Token.Type.ID);
							return new DeclareStatement((declToken.Value == "globalvar"), ParseDeclarations(), line);
						}

						case "if": // if (expr) stmt [else stmt]
						{
							NextToken(Token.Type.ID);
							NextToken(Token.Type.LeftPar);
							Expression cond = ParseExpr();
							NextToken(Token.Type.RightPar);
							Statement stmt = ParseStatement();
							if (PeekToken() == Token.Type.Terminator) // Optional semicolon
								NextToken(Token.Type.Terminator);
							Statement elseStmt = null;
							if (PeekToken() == Token.Type.ID && CurrentToken.Value == "else")
							{
								NextToken(Token.Type.ID);
								elseStmt = ParseStatement();
							}
							return new IfStatement(cond, stmt, elseStmt, line);
						}

						case "while": // while (expr) stmt
						{
							NextToken(Token.Type.ID);
							NextToken(Token.Type.LeftPar);
							Expression cond = ParseExpr();
							NextToken(Token.Type.RightPar);
							Statement stmt = ParseStatement();
							return new WhileStatement(cond, stmt, line);
						}

						case "do": // do stmt until expr
						{
							NextToken(Token.Type.ID);
							Statement stmt = ParseStatement();
							NextToken(Token.Type.ID, "until");
							NextToken(Token.Type.LeftPar);
							Expression cond = ParseExpr();
							NextToken(Token.Type.RightPar);
							return new DoUntilStatement(stmt, cond, line);
						}

						case "for": // for ([stmt]; [expr]; [stmt]) stmt
						{
							NextToken(Token.Type.ID);
							NextToken(Token.Type.LeftPar);
							Statement initStmt = null;
							Expression loopCond = null;
							Statement incStmt = null;

							// Init
							if (PeekToken() != Token.Type.Terminator)
								initStmt = ParseStatement();
							NextToken(Token.Type.Terminator);

							// Loop
							if (PeekToken() != Token.Type.Terminator)
								loopCond = ParseExpr();
							NextToken(Token.Type.Terminator);

							// Increment
							if (PeekToken() != Token.Type.RightBrace)
								incStmt = ParseStatement();

							NextToken(Token.Type.RightPar);
							return new ForStatement(initStmt, loopCond, incStmt, ParseStatement(), line);
						}

						case "repeat": // repeat (expr) stmt
						{
							NextToken(Token.Type.ID);
							NextToken(Token.Type.LeftPar);
							Expression cond = ParseExpr();
							NextToken(Token.Type.RightPar);
							Statement stmt = ParseStatement();
							return new RepeatStatement(cond, stmt, line);
						}

						case "with": // with (expr) stmt
						{
							NextToken(Token.Type.ID);
							NextToken(Token.Type.LeftPar);
							Expression cond = ParseExpr();
							NextToken(Token.Type.RightPar);
							Statement stmt = ParseStatement();
							return new WithStatement(cond, stmt, line);
						}

						case "switch": // switch (expr) { case expr1: stmtList ... [ default: stmtList ] }
						{
							NextToken(Token.Type.ID);

							NextToken(Token.Type.LeftPar);
							Expression expr = ParseExpr();
							NextToken(Token.Type.RightPar);
							List<SwitchStatement.Case> cases = new List<SwitchStatement.Case>();
							StatementList defaultStmts = null;

							NextToken(Token.Type.LeftBrace);
							while (PeekToken() != Token.Type.RightBrace)
							{
								Token caseToken = NextToken(Token.Type.ID);
								if (caseToken.Value == "case")
								{
									Expression caseExpr = ParseExpr();
									NextToken(Token.Type.Colon);
									cases.Add(new SwitchStatement.Case(caseExpr, ParseStatementList()));
								}
								else if (caseToken.Value == "default") // default
								{
									NextToken(Token.Type.Colon);
									defaultStmts = ParseStatementList();
								}
								else
									NextToken(Token.Type.Error);
							}
							NextToken(Token.Type.RightBrace);

							return new SwitchStatement(expr, cases, defaultStmts, line);
						}

						case "return": // return expr/;
						{
							NextToken(Token.Type.ID);
							if (PeekToken() == Token.Type.Terminator)
							{
								NextToken(Token.Type.Terminator);
								Return = new ReturnStatement(null, line);
							}
							else
								Return = new ReturnStatement(ParseExpr(), line);
							return Return;
						}

						case "break": // break
						{
							NextToken(Token.Type.ID);
							return new BreakStatement(line);
						}

						case "continue": // continue
						{
							NextToken(Token.Type.ID);
							return new ContinueStatement(line);
						}

						case "enum": // enum name { name [ = expr ], ... }
						{
							NextToken(Token.Type.ID);
							string enumName = NextToken(Token.Type.ID).Value;
							NextToken(Token.Type.LeftBrace);
							DeclarationList decls = ParseDeclarations();
							NextToken(Token.Type.RightBrace);
							return new EnumStatement(enumName, decls, line);
						}

						case "delete": // delete expr
						{
							NextToken(Token.Type.ID);
							return new DeleteStatement(ParseExpr(), line);
						}

						case "static":
						{
							if (StructObject == null)
							{
								Console.WriteLine("FATAL ERROR: Unexpected static in {0}:{1}.", Name, line);
								Environment.Exit(1);
							}
							Function func = new Function("", Gml);
							CurrentParseFunction = func;

							NextToken(Token.Type.ID);
							func.Name = NextToken(Token.Type.ID).Value;
							NextToken(Token.Type.Assign);
							NextToken(Token.Type.ID, "function");
							NextToken(Token.Type.LeftPar);
							func.Args = ParseDeclarations(true);
							NextToken(Token.Type.RightPar);
							NextToken(Token.Type.LeftBrace);
							func.Statements = ParseStatementList();
							NextToken(Token.Type.RightBrace);

							// Add new function to object
							func.StructObject = StructObject;
							func.Return = Return;
							if (func.Return == null)
								func.ReturnType = new DataType(DataType.Type.Void);
							StructObject.InstanceFunctions.Add(func.Name, func);

							CurrentParseFunction = this;
							Return = null;

							return null; // Skip in constructor statement list
						}

						default: // Call/Assign
						{
							Accessor accessor = ParseAccessor();
							switch (PeekToken())
							{
								case Token.Type.AddShort: // accessor++
								case Token.Type.SubShort: // accessor--
								{
									NextToken(LastPeeked);
									accessor.AddSubOp = LastPeeked;
									return new AssignStatement(accessor, LastPeeked, null, line);
								}
								case Token.Type.Assign: // accessor = expr
								case Token.Type.AddLong: // accessor += expr
								case Token.Type.SubLong: // accessor -= expr
								case Token.Type.MulLong: // accessor *= expr
								case Token.Type.DivLong: // accessor /= expr
								{
									NextToken(LastPeeked);
									return new AssignStatement(accessor, LastPeeked, ParseExpr(), line);
								}

								default: // accessor
									return new CallStatement(accessor, line);
							}
						}
					}
				}

				case Token.Type.LeftBrace: // { stmtList }
				{
					NextToken(Token.Type.LeftBrace);
					StatementList sl = ParseStatementList();
					NextToken(Token.Type.RightBrace);
					return sl;
				}
			}

			NextToken(Token.Type.Error);
			return null;
		}

		DeclarationList ParseDeclarations(bool isArgs = false)
		{
			List<Declaration> decls = new List<Declaration>();
			while (PeekToken() == Token.Type.ID)
			{
				if (GML.Keywords.Contains(CurrentToken.Value)) // GML keywords will break the declaration (var/globalvar)
					break;

				string name = NextToken(Token.Type.ID).Value;
				Expression expr = null;
				if (PeekToken() == Token.Type.Assign) // Found expression
				{
					NextToken(Token.Type.Assign);
					expr = ParseExpr();
				}
				decls.Add(new Declaration(name, expr));

				if (PeekToken() == Token.Type.Separator)
					NextToken(Token.Type.Separator);
				else
					break;
			}
			return new DeclarationList(decls, isArgs, CurrentParseLine);
		}

		Accessor ParseAccessor()
		{
			int line = CurrentParseLine;
			Token token = NextToken(Token.Type.ID);
			List<Accessor.ArrayAccessor> arrayAccessors = new List<Accessor.ArrayAccessor>();
			Accessor member = null;
			List<Expression> parameterList = null;
			Token.Type addSubOp = Token.Type.Unknown;

			if ((token.Value == "argument" || token.Value == "argument_count") && CppSeparateHeader == "") // Set VarArgs
				VarArgs = true;

			if (PeekToken() == Token.Type.LeftPar) // Parameter list
				parameterList = ParseParameterList();

			while (PeekToken() == Token.Type.LeftSquare) // Array accessors
			{
				NextToken(Token.Type.LeftSquare);
				DataType.Type arrAccType = DataType.Type.Array;
				bool isRef = false;

				// Look for token after [
				switch (PeekToken())
				{
					case Token.Type.ArrayRef: isRef = true; break;
					case Token.Type.BitwiseOr: arrAccType = DataType.Type.List; break;
					case Token.Type.Ternary: arrAccType = DataType.Type.AnyMap; break;
					case Token.Type.HashTag: arrAccType = DataType.Type.Grid; break;
				}
				if (isRef || arrAccType != DataType.Type.Array)
					NextToken(LastPeeked);

				arrayAccessors.Add(new Accessor.ArrayAccessor(arrAccType, ParseExpr(), isRef));

				// Look for comma separated list with more accessors
				while (PeekToken() == Token.Type.Separator)
				{
					NextToken(Token.Type.Separator);
					arrayAccessors.Add(new Accessor.ArrayAccessor(arrAccType, ParseExpr(), isRef));
				}
				NextToken(Token.Type.RightSquare);
			}

			if (PeekToken() == Token.Type.Member) // Member
			{
				NextToken(Token.Type.Member);
				member = ParseAccessor();
			}
			else if (PeekToken() == Token.Type.AddShort || PeekToken() == Token.Type.SubShort) // ++/--
			{
				addSubOp = LastPeeked;
				NextToken(LastPeeked);
			}


			return new Accessor(token.Value, arrayAccessors, parameterList, member, addSubOp, line);
		}

		Expression ParseExpr()
		{
			Expression expr = ParseExprAndOr();

			if (PeekToken() == Token.Type.Ternary) // ? expr2 : expr3
			{
				NextToken(Token.Type.Ternary);
				Expression expr2 = ParseExpr();
				NextToken(Token.Type.Colon);
				Expression expr3 = ParseExpr();
				return new TernaryCondition(expr, expr2, expr3, CurrentParseLine);
			}

			return expr;
		}

		Expression ParseExprAndOr()
		{
			Expression expr = ParseExprEq();
			if (PeekToken() == Token.Type.And || PeekToken() == Token.Type.Or)
			{
				NextToken(LastPeeked);
				return new BinaryOperation(LastPeeked, expr, ParseExprAndOr(), CurrentParseLine);
			}
			return expr;
		}

		Expression ParseExprEq()
		{
			Expression expr = ParseExprComp();
			if (PeekToken() == Token.Type.Assign || PeekToken() == Token.Type.Equal || PeekToken() == Token.Type.NotEqual)
			{
				NextToken(LastPeeked);
				Token.Type opType = LastPeeked;
				if (opType == Token.Type.Assign) // Change = to ==
					opType = Token.Type.Equal;
				return new BinaryOperation(opType, expr, ParseExprEq(), CurrentParseLine);
			}
			return expr;
		}

		Expression ParseExprComp()
		{
			Expression expr = ParseExprAddSub();
			if (PeekToken() == Token.Type.Larger || PeekToken() == Token.Type.LargerEq ||
				PeekToken() == Token.Type.Less || PeekToken() == Token.Type.LessEq)
			{
				NextToken(LastPeeked);
				return new BinaryOperation(LastPeeked, expr, ParseExprComp(), CurrentParseLine);
			}
			return expr;
		}

		Expression ParseExprAddSub()
		{
			Expression expr = ParseExprMulDiv();
			if (PeekToken() == Token.Type.Add || PeekToken() == Token.Type.Sub)
			{
				NextToken(LastPeeked);
				return new BinaryOperation(LastPeeked, expr, ParseExprAddSub(), CurrentParseLine);
			}
			return expr;
		}

		Expression ParseExprMulDiv()
		{
			Expression expr = ParseExprModInvNegate();
			if (PeekToken() == Token.Type.Mul || PeekToken() == Token.Type.Div || PeekToken() == Token.Type.DivInt ||
				PeekToken() == Token.Type.BitwiseAnd || PeekToken() == Token.Type.BitwiseOr ||
				PeekToken() == Token.Type.ShiftLeft || PeekToken() == Token.Type.ShiftRight)
			{
				NextToken(LastPeeked);
				return new BinaryOperation(LastPeeked, expr, ParseExprMulDiv(), CurrentParseLine);
			}
			return expr;
		}

		Expression ParseExprModInvNegate()
		{
			if (PeekToken() == Token.Type.Inverse || PeekToken() == Token.Type.Sub)
			{
				NextToken(LastPeeked);
				return new UnaryOperation(LastPeeked, ParseExprValue(), CurrentParseLine);
			}

			Expression expr = ParseExprValue();
			if (PeekToken() == Token.Type.Modulus)
			{
				NextToken(LastPeeked);
				return new BinaryOperation(LastPeeked, expr, ParseExprModInvNegate(), CurrentParseLine);
			}

			return expr;
		}

		Expression ParseExprValue()
		{
			switch (PeekToken())
			{
				case Token.Type.Number:
				case Token.Type.String: // Number/String
					return new ExpressionValue(LastPeeked, NextToken(LastPeeked).Value, CurrentParseLine);

				case Token.Type.ID: // ID [ arrayAccessors... ] [ . ]/[( parameterList )]
				{
					if (CurrentToken.Value == "new") // new accessor
					{
						NextToken(Token.Type.ID);
						return new NewExpression(ParseAccessor(), CurrentParseLine);
					}
					else
						return ParseAccessor();
				}

				case Token.Type.LeftSquare: // [ expr, ... ]
				{
					NextToken(Token.Type.LeftSquare);
					List<Expression> exprs = new List<Expression>();

					while (PeekToken() != Token.Type.RightSquare) // Comma separated array values
					{
						exprs.Add(ParseExpr());
						if (PeekToken() == Token.Type.Separator)
							NextToken(Token.Type.Separator);
					}
					NextToken(Token.Type.RightSquare);
					return new ExpressionArray(exprs, CurrentParseLine);
				}

				case Token.Type.LeftPar: // ( expr )
				{
					NextToken(Token.Type.LeftPar);
					Expression expr = ParseExpr();
					NextToken(Token.Type.RightPar);
					return new ExpressionParenthesis(expr, CurrentParseLine);
				}
			}

			return null;
		}

		List<Expression> ParseParameterList()
		{
			List<Expression> pars = new List<Expression>();
			NextToken(Token.Type.LeftPar);
			while (true)
			{
				if (PeekToken() == Token.Type.Separator)
					NextToken(Token.Type.Separator);
				else if (PeekToken() == Token.Type.RightPar)
					break;
				else
					pars.Add(ParseExpr());
			}
			NextToken(Token.Type.RightPar);
			return pars;
		}
	}
}
