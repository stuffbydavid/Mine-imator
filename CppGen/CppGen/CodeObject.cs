using System.Collections.Generic;

namespace CppGen
{
	// A statement or expression in the code.
	public abstract class CodeObject
	{
		public Function Func;
		public int Line;

		public static int TotalObjects = 0;
		public static int UnknownScopes = 0;

		public CodeObject(int line)
		{
			Func = Function.CurrentParseFunction;
			Line = line;
			TotalObjects++;
		}

		// Writes a variable name in a C++ safe format.
		static public string NameToCpp(string name)
		{
			switch (name)
			{
				case "app": return "_app";
				case "self": return "this";
				case "object_index": return "subAssetId";
				case "undefined": return "VarType()";
				case "block_size":
				case "char":
				case "double":
				case "export":
				case "far":
				case "float":
				case "inline":
				case "int":
				case "interface":
				case "near":
				case "NULL":
				case "null":
				case "pi":
				case "sample_rate":
				case "slots":
				case "small":
				case "template":
				case "typename":
				case "W":
				case "X":
				case "Y":
				case "Z":
					return name + "_";
			}
			return name;
		}

		// Adds object/function/global variables from within the CodeObject and saves the evaulated GML type.
		public virtual void Resolve(ResolveScope scope) {}
	}
}
