using System;
using System.Collections.Generic;

namespace CppGen
{
	// An instance, local or global variable
	public class Variable
	{
		public string Scope; // Can be an object name, function name, "global" or "" for unknown
		public string Name;
		public DataType Type;
		public int Line;
		public Statement.Location Location = null;
		public bool IsReference = false;

		public static int TotalVariables = 0;
		public static int VariantVariables = 0;

		public Variable(string scope, string name, DataType type, int line = 0, Statement.Location location = null)
		{
			Scope = scope;
			Name = name;
			if (Program.VarTypeOverride.ContainsKey(Name))
				Type = Program.VarTypeOverride[Name];
			else
				Type = new DataType(type);
			Line = line;
			Location = location;
			if (Location == null)
				Location = new Statement.Location();

			if (Scope != "")
			{
				TotalVariables++;
				VariantVariables += Type.IsCppVarType() ? 1 : 0;
			}
		}

		public bool AssignType(DataType type, Function func, int line)
		{
			if (Program.VarTypeOverride.ContainsKey(Name))
				return false;

			if (Scope != "")
				VariantVariables -= Type.IsCppVarType() ? 1 : 0;
			
			bool changed = Type.Assign(type, func, line);

			if (Scope != "")
				VariantVariables += Type.IsCppVarType() ? 1 : 0;
			return changed;
		}

		// Marks a function argument as a reference.
		public void MarkReference()
		{
			if (Line != 0 || !Program.Functions.ContainsKey(Scope))
				return;
			if (Program.Functions[Scope].VarArgs)
				Program.AddSyntaxError("@ operator not supported inside scripts using argument[] in " + Scope + ":" + Line);

			Type.Assign(new DataType(DataType.Type.Variant), null, 0); // Convert to VarType to allow .Arr()/.Ref(i)
			IsReference = true;

			foreach (Declaration decl in Program.Functions[Scope].Args.Declarations)
			{
				if (decl.Name == Name)
				{
					if (decl.Expr != null)
						Program.AddSyntaxError("@ operator only supported on arguments with no default value " + Scope + ":" + Line);

					decl.IsReference = true;
					return;
				}
			}
		}
	}
}
