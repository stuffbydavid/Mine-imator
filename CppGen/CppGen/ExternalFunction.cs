using System;
using System.Collections.Generic;
using System.Text;

namespace CppGen
{
	// Stores an external function whenever external_define is called.
	class ExternalFunction
	{
		public string Name;
		public DataType ReturnType;
		public List<DataType> ArgTypes;

		public ExternalFunction(string name, DataType returnType, List<DataType> argTypes)
		{
			Name = name;
			ReturnType = returnType;
			ArgTypes = argTypes;
		}

		// Writes the C++ header of the external function.
		public void WriteCppHeader()
		{
			CodeWriter.Write(ReturnType.ToCpp() + " " + CodeObject.NameToCpp(Name));

			CodeWriter.Write("(");
			int a = 0;
			foreach (DataType type in ArgTypes)
			{
				if (a++ > 0)
					CodeWriter.Write(", ");
				CodeWriter.Write(type.ToCpp());
			}
			CodeWriter.WriteLine(");");
		}
	}
}
