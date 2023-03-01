using System;
using System.Collections.Generic;
using System.IO;

namespace CppGen
{
	// A GameMaker object or a struct in the code.
	// For objects, the Create Event is the constructor and Destroy Event the destructor.
	// For structs, the declaration is the contructor, with no destructor. Static functions are added into InstanceFunctions.
	public class Object
	{
		public string Name;
		public Function CreateFunction = null;
		public Function DestroyFunction = null;
		public Function Constructor = null;
		public Function Destructor = null;
		public Dictionary<string, Function> InstanceFunctions = new Dictionary<string, Function>();
		public Dictionary<string, Variable> InstanceVars = new Dictionary<string, Variable>();
		public bool IsStruct = false;
		
		private bool ImplWritten = false;

		public Object(string name, bool isStruct)
		{
			Name = name;
			IsStruct = isStruct;
		}

		public Object(string dir) : this("", false)
		{
			DirectoryInfo dirInfo = new DirectoryInfo(dir);
			Name = dirInfo.Name;

			// Parse selected events and their script
			string[] objectEventFiles = Directory.GetFiles(dir, "*.gml");
			foreach (string eventFile in objectEventFiles)
			{
				FileInfo eventFileInfo = new FileInfo(eventFile);
				string gml = File.ReadAllText(eventFile);
				string funcName = gml.Replace("()", "").Replace(";", "").Trim();

				if (!Program.Functions.ContainsKey(funcName))
					continue;
				Function func = Program.Functions[funcName];

				if (eventFileInfo.Name == "Create_0.gml")
					CreateFunction = func;
				else if (eventFileInfo.Name == "Destroy_0.gml")
					DestroyFunction = func;
				else if (dirInfo.Name == "app")
				{
					switch (eventFileInfo.Name)
					{
						case "Draw_0.gml": Program.AppDrawFunction = func; break;
						case "Other_3.gml": Program.AppGameEndFunction = func; break;
						case "Other_62.gml": Program.AppHttpFunction = func; break;
						case "Step_0.gml": Program.AppStepFunction = func; break;
						default:
						{
							Console.WriteLine("WARNING: Unsupported event {0} in {1}, it will be ignored.", eventFileInfo.Name, "app");
							break;
						}
					}
				}
				else
					Console.WriteLine("WARNING: Unsupported event {0} in {1}, it will be ignored." + eventFileInfo.Name, dirInfo.Name);
			}
		}

		// Sets the constructor of the object.
		public void SetConstructor(Function func)
		{
			Constructor = func;
			func.StructObject = this;
			func.IsConstructor = true;
			func.CppLinesBegin.Add("InitMembers();");
		}

		// Sets the destructor of the object.
		public void SetDestructor(Function func)
		{
			Destructor = func;
			func.StructObject = this;
			func.IsDestructor = true;
		}

		// Writes the C++ header of the object.
		public void WriteCppHeader()
		{
			CodeWriter.WriteLine("struct " + Name + ": Object");
			CodeWriter.WriteLine("{", 1);

			// Variables
			foreach (Variable var in InstanceVars.Values)
				if (var.Name != "id" && var.Name != "subAssetId")
					CodeWriter.WriteLine(var.Type.ToCpp() + " " + CodeObject.NameToCpp(var.Name) + ";");

			if (Constructor != null || Destructor != null || InstanceFunctions.Values.Count > 0)
				CodeWriter.WriteLine();

			// Constructor header
			if (Constructor != null)
			{
				CodeWriter.Write(Name + "(");
				if (Constructor.Args != null)	
					Constructor.Args.WriteCpp(new ResolveScope("global"), DeclarationList.WriteFormat.ArgsHeader);
				CodeWriter.WriteLine(");");
			}

			// Destructor header
			if (Destructor != null)
				CodeWriter.WriteLine("~" + Name + "();");

			CodeWriter.WriteLine("void InitMembers() override;");

			// Instance functions
			foreach (Function func in InstanceFunctions.Values)
				func.WriteCppHeader();

			CodeWriter.WriteLine("};", -1);
		}

		// Writes the C++ implementation of the object. Returns whether anything was written.
		public bool WriteCppImplementation()
		{
			if (ImplWritten)
				return false;
			ImplWritten = true;

			// Constructor
			if (Constructor != null)
				Constructor.WriteCppImplementation();

			// Destructor
			if (Destructor != null)
				Destructor.WriteCppImplementation();

			foreach (Function func in InstanceFunctions.Values)
				func.WriteCppImplementation();
			return true;
		}

		// Writes the commands for storing the memory locations of each object member and functions.
		public void WriteInitMembers()
		{
			CodeWriter.WriteLine("void " + Name + "::InitMembers()");
			CodeWriter.WriteLine("{", 1);

			// Define instance functions for use with the idFunc macro
			if (InstanceFunctions.Count > 0)
			{
				foreach (Function func in InstanceFunctions.Values)
					CodeWriter.WriteLine("DefineObjectFunction(ID_" + Name + ", M_" + func.Name + ", " + func.ToExecuteCpp() + ")");
				CodeWriter.WriteLine();
			}

			CodeWriter.WriteLine("if (memberMap.contains(ID_" + Name + "))", 1);
			CodeWriter.WriteLine("return;");
			CodeWriter.WriteLine("", -1);

			// Define members
			foreach (Variable var in InstanceVars.Values)
				CodeWriter.WriteLine("DefineObjectMember(ID_" + Name + ", M_" + CodeObject.NameToCpp(var.Name) + ", " + CodeObject.NameToCpp(var.Name) + ", " + var.Type.ToCppEnum() + ");");
			
			CodeWriter.WriteLine("}", -1);
			CodeWriter.WriteLine();
		}

		// Returns a string containing the functions and variables of the object.
		public string ToDebugString(string tabs = "")
		{
			string str = tabs + Name + ":\n";
			tabs += "\t";
			if (Constructor != null)
				str += tabs + "Constructor: " + Constructor.Name + "\n";
			if (Destructor != null)
				str += tabs + "Destructor: " + Destructor.Name + "\n";
			str += tabs + "LocalFunctions:\n";
			foreach (Function func in InstanceFunctions.Values)
				str += func.ToDebugString(tabs + "\t");
			str += tabs + "Variables:\n";
			tabs += "\t";
			foreach (Variable var in InstanceVars.Values)
				str += tabs + var.Type.ToCpp() + " " + var.Name + "\n" + var.Type.GetAssignmentsString(tabs + "\t");
			return str;
		}
	}
}
