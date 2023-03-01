using System;
using System.Collections.Generic;

namespace CppGen
{
	// Generic statement
	public abstract class Statement : CodeObject
	{
		public Type type;
		public bool HasCpp = true;
		public Location location;

		public enum Type
		{
			DeclarationList,
			StatementList,
			Declare,
			Macro,
			Enum,
			Call,
			Assign,
			If,
			While,
			DoUntil,
			For,
			Repeat,
			With,
			Switch,
			Break,
			Continue,
			Return,
			Delete,
			CustomCpp
		}

		// A location of a statement in a function.
		public class Location
		{
			public List<int> Path = new List<int>(); // Empty list for root, remaining are a sequence of int Ids
			public int Level = 0;
			private int NextId = 0;

			public Location() { }

			public Location(Location other)
			{
				Path = new List<int>(other.Path);
				Level = other.Level;
				NextId = other.NextId;
			}

			// Returns the next location.
			public Location Next(bool addLevel = false)
			{
				Location next = new Location();
				next.Path = new List<int>(Path);
				next.Level = Level + (addLevel ? 1 : 0);
				next.Path.Add(NextId++);
				return next;
			}


			// Returns whether the given location is a statement inside this one.
			public bool Contains(Location other)
			{
				if (Path.Count > other.Path.Count)
					return false;

				for (int i = 0; i < Path.Count; i++)
					if (other.Path[i] != Path[i])
						return false;

				return true;
			}

			// Returns whether this location equals another.
			public bool Equals(Location other)
			{
				if (Path.Count != other.Path.Count)
					return false;

				for (int i = 0; i < Path.Count; i++)
					if (other.Path[i] != Path[i])
						return false;

				return true;
			}

			public override string ToString()
			{
				string str = "";
				foreach (int p in Path)
					str += (str != "" ? " -> " : "") + p;
				return "[" + str + "]";
			}
		}

		protected Statement(int line) : base(line)
		{
		}

		// Write the C++ code of the statement using the CodeWriter class.
		public virtual void WriteCpp(ResolveScope scope)
		{
		}
	}

	// Generic declaration
	public class Declaration
	{
		public string Name;
		public Expression Expr;
		public bool IsReference = false;

		public Declaration(string name, Expression expr)
		{
			Name = name;
			Expr = expr;
		}
	}

	// List of local or global declarations
	public class DeclarationList : Statement
	{
		public List<Declaration> Declarations;
		public bool IsEnum = false;
		public bool IsArgs = false;
		public int RequiredArgs = 0;

		public DeclarationList(List<Declaration> declarations, bool isArgs, int line) : base(line)
		{
			Declarations = declarations;
			IsArgs = isArgs;

			type = Type.DeclarationList;
		}

		// Resolve declaration types, returns if they have changed since last time from the given input.
		public bool Resolve(ResolveScope scope, string declScope, List<DataType> inputPars = null)
		{
			location = scope.Location;

			bool changed = false;

			int i = 0;
			RequiredArgs = 0;

			foreach (Declaration decl in Declarations)
			{
				// Check if name is a duplicate
				for (int j = 0; j < i; j++)
					if (Declarations[j].Name == decl.Name)
						Program.AddSyntaxError("Duplicate declaration of " + decl.Name + " in " + Func.Name + ":" + Line);

				DataType exprType = new DataType();
				if (decl.Expr != null) // Attempt getting type from expression
				{
					decl.Expr.Resolve(scope);
					exprType = new DataType(decl.Expr.ResolvedType);
				}
				else
					RequiredArgs = i + 1;

				// If input if supplied, apply to the expression
				if (inputPars != null && i < inputPars.Count)
					if (exprType.Assign(new DataType(inputPars[i]), Func, IsArgs ? 0 : Line))
						changed = true;

				Variable declVar = Program.DeclareVariable(declScope, decl.Name, exprType, Func, scope.Location, IsArgs ? 0 : Line);

				if (decl.Expr != null)
					decl.Expr.AssignedTo = declVar;
				i++;
			}

			return changed;
		}

		public enum WriteFormat
		{
			ArgsHeader, // type1 arg1, type2 arg2 [= expr]...
			ArgsImpl, // type1 arg1, type2 arg2...
			Var, // int int1 [= expr], int2 [= expr];\n double db1 [= expr], db2 [= expr]; ...
			Enum // enumName_name1 [= expr],\n enumName_name2 [= expr] ...
		}

		public void WriteCpp(ResolveScope scope, WriteFormat format, string enumPrefix = "")
		{
			List<DataType> varTypes = new List<DataType>(); // Get variable types
			if (!IsEnum)
			{
				foreach (Declaration decl in Declarations)
				{
					Variable var = Program.FindVariable(Func.Name, decl.Name, Func, scope.Location, Line);
					varTypes.Add(var.Type);
				}
			}

			if (format == WriteFormat.Var) // One type per line
			{
				List<int> declToWrite = new List<int>(); // The declaration indices left to write
				for (int i = 0; i < Declarations.Count; i++)
					declToWrite.Add(i);

				bool newLine = false;
				for (int j = 0; j < Declarations.Count; j++)
				{
					if (declToWrite.Contains(j))
					{
						if (newLine)
							CodeWriter.WriteLine();
						string typeCpp = varTypes[j].ToCpp();
						CodeWriter.Write(typeCpp + " ");

						int jj = 0, rowCount = 0;
						foreach (Declaration decl in Declarations)
						{
							if (declToWrite.Contains(jj) && typeCpp == varTypes[jj].ToCpp()) // Write all declarations that match this type
							{
								declToWrite.RemoveAll((int i) => (i == jj));

								if (rowCount++ > 0)
									CodeWriter.Write(", ");

								CodeWriter.Write(NameToCpp(decl.Name));
								if (decl.Expr != null)
									CodeWriter.Write(" = " + decl.Expr.ToCpp(scope));
							}
							jj++;
						}
						CodeWriter.Write(";");
						newLine = true;
					}
				}
			}
			else if (format == WriteFormat.Enum) // New line for each declaration
			{
				int i = 0;
				foreach (Declaration decl in Declarations)
				{
					if (i > 0)
						CodeWriter.WriteLine(",");
					CodeWriter.Write(NameToCpp(enumPrefix) + "_" + NameToCpp(decl.Name)); // Name (with prefix)

					if (decl.Expr != null) // Expression
						CodeWriter.Write(" = " + decl.Expr.ToCpp(scope));
					i++;
				}
				CodeWriter.WriteLine();
			}
			else // Single line for all declarations
			{
				int i = 0;
				foreach (Declaration decl in Declarations)
				{
					if (i > 0)
						CodeWriter.Write(", ");
					CodeWriter.Write(varTypes[i].ToCpp() + " " + NameToCpp(decl.Name));
					if (decl.Expr != null && format != WriteFormat.ArgsImpl) // Expression
						CodeWriter.Write(" = " + decl.Expr.ToCpp(scope));
					i++;
				}
			}
		}
	}

	// Statement list
	public class StatementList : Statement
	{
		public List<Statement> Statements;

		public StatementList(int line) : base(line)
		{
			Statements = new List<Statement>();
			type = Type.StatementList;
		}

		public void AddStatement(Statement stmt)
		{
			Statements.Add(stmt);
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope stmtsScope = scope.NextStatement();

			foreach (Statement stmt in Statements)
				stmt.Resolve(stmtsScope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			WriteCpp(scope, true);
		}

		public void WriteCpp(ResolveScope scope, bool brackets)
		{
			if (brackets)
			{
				CodeWriter.Indent(-1);
				CodeWriter.WriteLine("{", 1);
			}
			else
				CodeWriter.Indent(1);

			if (scope.Location.Path.Count == 0 && Func.CppLinesBegin.Count > 0)
			{
				foreach (string line in Func.CppLinesBegin)
					CodeWriter.WriteLine(line);
				Func.CppLinesBegin.Clear();
			}

			ResolveScope stmtsScope = scope.NextStatement();
			foreach (Statement stmt in Statements)
			{
				if (stmt.type == Type.Enum)
					continue;
				stmt.WriteCpp(stmtsScope);
				if (stmt.HasCpp)
					CodeWriter.WriteLine();
			}

			if (scope.Location.Path.Count == 0 && Func.CppLinesEnd.Count > 0)
			{
				foreach (string line in Func.CppLinesEnd)
					CodeWriter.WriteLine(line);
				Func.CppLinesEnd.Clear();
			}

			if (brackets)
			{
				CodeWriter.Indent(-1);
				CodeWriter.Write("}");
				CodeWriter.Indent(1);
			}
			else
				CodeWriter.Indent(-1);
		}
	}

	// Declare variable statement (var/globalvar)
	public class DeclareStatement : Statement
	{
		public bool GlobalScope;
		public DeclarationList Declarations;
		public static List<DeclareStatement> GlobalDeclarations = new List<DeclareStatement>();

		public DeclareStatement(bool globalScope, DeclarationList declarations, int line) : base(line)
		{
			GlobalScope = globalScope;
			Declarations = declarations;
			if (globalScope)
				GlobalDeclarations.Add(this);
			type = Type.Declare;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);

			Declarations.Resolve(scope, GlobalScope ? "global" : Func.Name);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			if (GlobalScope)
			{
				HasCpp = false;
				return;
			}

			Declarations.WriteCpp(scope, DeclarationList.WriteFormat.Var);
		}
	}

	// Define macro statement
	public class MacroStatement : Statement
	{
		public string Name;
		public Expression Expr;

		public MacroStatement(string name, Expression expr, int line) : base(line)
		{
			Name = name;
			Expr = expr;
			type = Type.Macro;

			Program.Macros.Add(Name, this);
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			Expr.Resolve(new ResolveScope("global", "", scope.Calls));
			Program.DeclareVariable("global", Name, Expr.ResolvedType, Func, scope.Location);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			CodeWriter.Write("#define " + NameToCpp(Name) + " ");
			CodeWriter.Write(Expr.ToCpp(scope));
			CodeWriter.WriteLine();
		}
	}

	// Enum statement
	public class EnumStatement : Statement
	{
		public string Name;
		public DeclarationList Declarations;

		public EnumStatement(string name, DeclarationList declarations, int line) : base(line)
		{
			Name = name;
			Declarations = declarations;
			Declarations.IsEnum = true;
			type = Type.Enum;

			Program.Enums.Add(Name, this);
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			CodeWriter.WriteLine("enum " + NameToCpp(Name));
			CodeWriter.WriteLine("{", 1);
			Declarations.WriteCpp(scope, DeclarationList.WriteFormat.Enum, Name);
			CodeWriter.WriteLine("};", -1);
		}
	}

	// Call statement
	public class CallStatement : Statement
	{
		public Accessor Acc;

		public CallStatement(Accessor accessor, int line) : base(line)
		{
			Acc = accessor;
			type = Type.Call;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			Acc.Resolve(scope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			if (Acc.Name == "gml_pragma")
			{
				HasCpp = false;
				return;
			}
			CodeWriter.Write(Acc.ToCpp(scope) + ";");
		}
	}

	// Assign statement
	public class AssignStatement : Statement
	{
		public Accessor Target;
		public Token.Type Op;
		public Expression Expr;

		public AssignStatement(Accessor target, Token.Type op, Expression expression, int line) : base(line)
		{
			Target = target;
			Target.MarkAsAssign(expression);
			Op = op;
			Expr = expression;
			type = Type.Assign;

			// Add external function
			if (Expr.type == Expression.Type.Accessor)
			{
				Accessor acc = (Accessor)Expr;
				if (acc.Name == "external_define" && acc.CallParameters != null && acc.CallParameters.Count >= 5)
				{
					// Get return type from arg[3], argument types from arg[5...]
					DataType retType = new DataType(((Accessor)acc.CallParameters[3]).Name == "ty_real" ? DataType.Type.Real : DataType.Type.String);

					List<DataType> argTypes = new List<DataType>();
					for (int a = 5; a < acc.CallParameters.Count; a++)
						argTypes.Add(new DataType(((Accessor)acc.CallParameters[a]).Name == "ty_real" ? DataType.Type.Real : DataType.Type.String));

					Program.ExternalFunctions.Add(Target.Name, new ExternalFunction(Target.Name, retType, argTypes));
				}
			}
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);

			switch (Op)
			{
				case Token.Type.AddShort: // ++, --, -=, *=, /= must be integer or double
				case Token.Type.SubShort:
				case Token.Type.SubLong:
				case Token.Type.MulLong:
				case Token.Type.DivLong:
				{
					Target.Resolve(scope);
					Target.ApplyType(scope, new DataType(DataType.Type.Real));
					if (Expr != null)
					{
						Expr.Resolve(scope);
						Expr.ApplyType(scope, new DataType(DataType.Type.Real));
					}
					break;
				}
				case Token.Type.Assign: // =, += must be same as expression
				case Token.Type.AddLong:
				{
					Target.Resolve(scope);
					Expr.Resolve(scope);
					Target.ApplyType(scope, Expr.ResolvedType);
					break;
				}
				default:
					Console.WriteLine("FATAL ERROR: Invalid token in {0}:{1}", Func.Name, Line);
					break;
			}
		}

		public override void WriteCpp(ResolveScope scope)
		{
			CodeWriter.Write(Target.ToCpp(scope));
			if (Expr != null)
			{
				CodeWriter.Write(" " + Token.ToCpp(Op) + " " + Expr.ToCpp(scope));

				if (Target.WrittenType.cppType == DataType.CppType.StringType &&
					Expr.GetResolvedCppType() == DataType.CppType.VarType) // VarType assigment to StringType (may fail)
					CodeWriter.Write(".Str()");

				CodeWriter.Write(";");
			}
		}
	}

	// If statement
	public class IfStatement : Statement
	{
		public Expression Condition;
		public Statement Statement;
		public Statement ElseStatement;

		public IfStatement(Expression condition, Statement statement, Statement elseStatement, int line) : base(line)
		{
			Condition = condition;
			Statement = statement;
			ElseStatement = elseStatement;
			type = Type.If;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope ifScope = scope.NextStatement();
			ResolveScope elseScope = null;
			if (ElseStatement != null)
				elseScope = scope.NextStatement();

			Condition.Resolve(ifScope);
			Statement.Resolve(ifScope);

			if (ElseStatement != null)
				ElseStatement.Resolve(elseScope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			ResolveScope ifScope = scope.NextStatement();
			ResolveScope elseScope = null;
			if (ElseStatement != null)
				elseScope = scope.NextStatement();

			CodeWriter.WriteLine("if (" + Condition.ToConditionCpp(ifScope, false) + ")", 1);
			Statement.WriteCpp(ifScope);
			CodeWriter.Indent(-1);

			if (ElseStatement != null)
			{
				if (!CodeWriter.IsNewLine)
					CodeWriter.WriteLine();
				CodeWriter.WriteLine("else", 1);
				ElseStatement.WriteCpp(elseScope);
				CodeWriter.WriteLine("", -1);
			}
		}
	}

	// While statement
	public class WhileStatement : Statement
	{
		public Expression LoopCondition;
		public Statement Statement;

		public WhileStatement(Expression loopCondition, Statement statement, int line) : base(line)
		{
			LoopCondition = loopCondition;
			Statement = statement;
			type = Type.While;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope whileScope = scope.NextStatement();

			LoopCondition.Resolve(whileScope);
			Statement.Resolve(whileScope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			ResolveScope whileScope = scope.NextStatement();
			CodeWriter.WriteLine("while (" + LoopCondition.ToConditionCpp(whileScope, false) + ")", 1);
			Statement.WriteCpp(whileScope);
			CodeWriter.WriteLine("", -1);
		}
	}

	// Do statement
	public class DoUntilStatement : Statement
	{
		public Statement Statement;
		public Expression BreakCondition;

		public DoUntilStatement(Statement statement, Expression breakCondition, int line) : base(line)
		{
			Statement = statement;
			BreakCondition = breakCondition;
			type = Type.DoUntil;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope stmtScope = scope.NextStatement();

			Statement.Resolve(stmtScope);
			BreakCondition.Resolve(scope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			ResolveScope stmtScope = scope.NextStatement();
			CodeWriter.WriteLine("do", 1);
			Statement.WriteCpp(stmtScope);
			CodeWriter.WriteLine("", -1);
			CodeWriter.Write("while (!(" + BreakCondition.ToConditionCpp(scope, false) + "));");
		}
	}

	// For statement
	public class ForStatement : Statement
	{
		public Statement InitStatement;
		public Expression LoopCondition;
		public Statement IncStatement;
		public Statement Statement;

		public ForStatement(Statement initStatement, Expression loopCondition, Statement incStatement, Statement statement, int line) : base(line)
		{
			InitStatement = initStatement;
			LoopCondition = loopCondition;
			IncStatement = incStatement;
			Statement = statement;
			type = Type.For;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope forScope = scope.NextStatement();

			if (InitStatement != null) // Initialize
				InitStatement.Resolve(forScope);

			if (LoopCondition != null) // Loop
			{
				LoopCondition.Resolve(forScope);
				LoopCondition.ApplyType(forScope, new DataType(DataType.Type.Bool));
			}

			if (IncStatement != null) // Increment
				IncStatement.Resolve(forScope);

			Statement.Resolve(forScope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			ResolveScope forScope = scope.NextStatement();
			CodeWriter.Write("for (");

			if (InitStatement != null)
			{
				InitStatement.WriteCpp(forScope);
				CodeWriter.Write(" ");
			}
			else
				CodeWriter.Write("; ");

			if (LoopCondition != null)
				CodeWriter.Write(LoopCondition.ToConditionCpp(forScope, false));
			CodeWriter.Write("; ");

			IncStatement?.WriteCpp(forScope);
			if (IncStatement != null)
				CodeWriter.Erase(1); // Remove ;
			CodeWriter.WriteLine(")", 1);
			Statement.WriteCpp(forScope);
			CodeWriter.Indent(-1);
		}
	}

	// Repeat statement
	public class RepeatStatement : Statement
	{
		public Expression Expr;
		public Statement Statement;

		public RepeatStatement(Expression expr, Statement statement, int line) : base(line)
		{
			Expr = expr;
			Statement = statement;
			type = Type.Repeat;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope repeatScope = scope.NextStatement();

			Expr.Resolve(repeatScope);
			Expr.ApplyType(repeatScope, new DataType(DataType.Type.Integer));
			Statement.Resolve(repeatScope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			ResolveScope repeatScope = scope.NextStatement();
			CodeWriter.WriteLine("for (IntType _it = 0, _it_max = " + Expr.ToCpp(repeatScope) + "; _it < _it_max; _it++)", 1);
			Statement.WriteCpp(repeatScope);
			CodeWriter.Indent(-1);
		}
	}

	// With statement
	public class WithStatement : Statement
	{
		public Expression Expr;
		public Statement Statement;
		public static bool ResolveUnknownScope = false;
		public List<string> OtherScopes = new List<string>();
		public string OtherScope = "";

		public WithStatement(Expression expression, Statement statement, int line) : base(line)
		{
			Expr = expression;
			Statement = statement;
			type = Type.With;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope withScope = scope.NextStatement(true);

			// Update scope of "other" keyword
			if (!OtherScopes.Contains(scope.Current))
				OtherScopes.Add(scope.Current);
			OtherScope = (OtherScopes.Count == 1) ? OtherScopes[0] : "any";

			Expr.Resolve(withScope);
			string newScope = Expr.ResolvedType.GetUniqueReferenceId();
			string exprAccName = Expr.GetAccessorName();
			if (Program.Objects.ContainsKey(exprAccName)) // with (objName)
				newScope = exprAccName;

			if (newScope == "")
				newScope = "any";

			if (newScope == "any")
			{
				UnknownScopes++;
				if (!ResolveUnknownScope)
					return;
			}

			// Continue with the scope set to the reference ID or "any" (and drop FuncUpdateScope)
			Statement.Resolve(withScope.EnterWithStatement(newScope, OtherScope));
		}

		public override void WriteCpp(ResolveScope scope)
		{
			ResolveScope withScope = scope.NextStatement(true);
			bool exprIsTypeId = false;
			string newScope = DataType.AllVarType ? "any" : Expr.ResolvedType.GetUniqueReferenceId();
			string otherScope = DataType.AllVarType ? "any" : OtherScope;

			string exprAccName = Expr.GetAccessorName();
			if (Program.Objects.ContainsKey(exprAccName)) // with (objName)
			{
				newScope = exprAccName;
				exprIsTypeId = (newScope != "app");
			}
			if (newScope == "")
				newScope = "any";

			string withType, otherId;
			if (newScope == "any")
				withType = "Object";
			else
				withType = newScope;

			if (withScope.Current != "global") // "other" will only work in non-global scopes, otherwise will be "noone"
			{
				if (Func.StructObject != null) // Use "id" member directly
					otherId = "id";
				else if (OtherScope == "app") // Get global app id
					otherId = "global::_app->id";
				else
					otherId = "self->id";
			}
			else
				otherId = "noone";

			if (exprIsTypeId) // Loop
				CodeWriter.WriteLine("withAll (" + withType + ", " + otherId + ")", 1);

			else // Single
				CodeWriter.WriteLine("withOne (" + withType + ", " + Expr.ToCpp(withScope) + ", " + otherId + ")", 1);

			Statement.WriteCpp(withScope.EnterWithStatement(newScope, otherScope));
			CodeWriter.WriteLine("", -1);
		}
	}

	// Switch statement
	public class SwitchStatement : Statement
	{
		public Expression Expr;
		public List<Case> Cases;
		public StatementList DefaultStatements;
		public DataType CaseResolvedType;

		// Case
		public class Case
		{
			public Expression Expr;
			public StatementList Statements;

			public Case(Expression expression, StatementList statements)
			{
				Expr = expression;
				Statements = statements;
			}
		}

		public SwitchStatement(Expression expression, List<Case> cases, StatementList defaultStatements, int line) : base(line)
		{
			Expr = expression;
			Cases = cases;
			DefaultStatements = defaultStatements;
			type = Type.Switch;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			ResolveScope switchScope = scope.NextStatement();

			Expr.Resolve(switchScope);

			CaseResolvedType = new DataType();
			foreach (Case switchCase in Cases) // Resolve cases
			{
				switchCase.Expr.Resolve(switchScope);
				CaseResolvedType = new DataType(switchCase.Expr.ResolvedType); // Derive expression type from cases
				switchCase.Expr.ApplyType(switchScope, new DataType(DataType.Type.Integer));
				switchCase.Statements.Resolve(switchScope);
			}

			// Apply case type to expression
			Expr.ApplyType(switchScope, CaseResolvedType);

			if (DefaultStatements != null) // Resolve default
				DefaultStatements.Resolve(switchScope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			ResolveScope switchScope = scope.NextStatement();

			// String switch
			if (CaseResolvedType.GetAssignments(DataType.Type.String).Count > 0)
			{
				CodeWriter.WriteLine("switch (StringType(" + Expr.ToCpp(switchScope) + ").id)");
				CodeWriter.WriteLine("{", 1);
				foreach (Case switchCase in Cases)
				{
					string val = ((ExpressionValue)switchCase.Expr).Value;
					CodeWriter.WriteLine("case " + Program.Strings.IndexOf(val) + ": // " + val);
					if (switchCase.Statements.Statements.Count > 0) // Has statements
					{
						bool indent = (switchCase.Statements.Statements[0].type != Type.StatementList);
						if (indent)
							CodeWriter.Indent(1);
						switchCase.Statements.WriteCpp(switchScope, indent);
						CodeWriter.WriteLine();
						if (indent)
							CodeWriter.Indent(-1);
					}
					else
						switchScope.NextStatement(); // Still increment scope
				}

				if (DefaultStatements != null) // Default
				{
					CodeWriter.WriteLine("default:");
					DefaultStatements.WriteCpp(switchScope, false);
				}
				CodeWriter.WriteLine("}", -1);
			}

			// Regular switch
			else
			{
				CodeWriter.WriteLine("switch ((IntType)" + Expr.ToCpp(switchScope) + ")");
				CodeWriter.WriteLine("{", 1);

				foreach (Case switchCase in Cases) // Cases
				{
					CodeWriter.WriteLine("case " + switchCase.Expr.ToCpp(switchScope) + ":");
					if (switchCase.Statements.Statements.Count > 0) // Has statements
					{
						bool indent = (switchCase.Statements.Statements[0].type != Type.StatementList);
						if (indent)
							CodeWriter.Indent(1);
						switchCase.Statements.WriteCpp(switchScope, indent);
						CodeWriter.WriteLine();
						if (indent)
							CodeWriter.Indent(-1);
					}
					else
						switchScope.NextStatement(); // Still increment scope
				}

				if (DefaultStatements != null) // Default
				{
					CodeWriter.WriteLine("default:");
					DefaultStatements.WriteCpp(switchScope, false);
				}

				CodeWriter.WriteLine("}", -1);
			}
		}
	}

	// Break statement
	public class BreakStatement : Statement
	{
		public BreakStatement(int line) : base(line)
		{
			type = Type.Break;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			CodeWriter.Write("break;");
		}
	}

	// Continue statement
	public class ContinueStatement : Statement
	{
		public ContinueStatement(int line) : base(line)
		{
			type = Type.Continue;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			CodeWriter.Write("continue;");
		}
	}

	// Return statement
	public class ReturnStatement : Statement
	{
		public Expression Expr;

		public ReturnStatement(Expression expr, int line) : base(line)
		{
			Expr = expr;
			type = Type.Return;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);

			if (Expr == null)
			{
				Func.AssignReturnType(new DataType(DataType.Type.Void), Func, Line);
				return;
			}

			Expr.Resolve(scope);

			if (Expr.ResolvedType.cppType != DataType.CppType.Void)
				Func.AssignReturnType(new DataType(Expr.ResolvedType), Func, Line);
			else
				Console.WriteLine("WARNING: Returning void type in {0}:{1}", Func.Name, Line);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			if (Expr != null)
				CodeWriter.Write("return " + Expr.ToCpp(scope) + ";");
			else
				CodeWriter.Write("return;");
		}
	}

	// Delete statement
	public class DeleteStatement : Statement
	{
		public Expression Expr;

		public DeleteStatement(Expression expr, int line) : base(line)
		{
			Expr = expr;
			type = Type.Delete;
		}

		public override void Resolve(ResolveScope scope)
		{
			location = new Location(scope.Location);
			Expr.Resolve(scope);
		}

		public override void WriteCpp(ResolveScope scope)
		{
			CodeWriter.Write("delete Obj(" + Expr.ToCpp(scope) + ");");
		}
	}

	// Custom C++ statement
	public class CustomCppStatement : Statement
	{
		public string Cpp;

		public CustomCppStatement(string cpp, int line) : base(line)
		{
			Cpp = cpp;
			type = Type.CustomCpp;
		}

		public override void Resolve(ResolveScope scope)
		{
		}

		public override void WriteCpp(ResolveScope scope)
		{
			CodeWriter.Write(Cpp);
		}
	}
}
