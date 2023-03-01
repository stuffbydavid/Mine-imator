using System;
using System.Collections.Generic;

namespace CppGen
{
	// Stores the possible data types of a variable, function argument or return type.
	public class DataType
	{
		public List<Assignment> Assignments = new List<Assignment>();
		public CppType cppType = CppType.VarType;

		// Can be set for debugging purposes the geneate all types as VarType.
		static public bool AllVarType = false;

		// Set automatically when generating code that needs types.
		static public bool IgnoreAllVarType = false;

		// Stores a possible data type and what function it got assigned first.
		public class Assignment
		{
			public Type RawType;
			public string RefId = ""; // Object name
			public DataType ContainerType = null;
			public Function Func;
			public int Line;

			public Assignment(Assignment other, Function func = null, int line = 0)
			{
				RawType = other.RawType;
				RefId = other.RefId;
				if (other.ContainerType != null)
					ContainerType = new DataType(other.ContainerType);
				Func = func;
				Line = line;
			}

			public Assignment(Type type, string refId, DataType containerType, Function func = null, int line = 0)
			{
				RawType = type;
				RefId = refId;
				ContainerType = containerType;
				Func = func;
				Line = line;
			}

			// Returns the assignment in string form with <> for containers/references.
			public override string ToString()
			{
				if (RawType >= Type.Array) // Container
					return RawType.ToString() + "<" + ContainerType.ToString() + ">";
				else if (RawType == Type.Reference) // Reference
					return RawType.ToString() + "<" + RefId + ">";
				else
					return RawType.ToString();
			}
		}

		public enum Type
		{
			Unknown,
			Variant,
			Null,
			Void,
			Bool,
			IntOrReal,
			Integer,
			Real,
			String,
			Reference,
			Array,
			Vector,
			Matrix,
			List,
			AnyMap,
			IntMap,
			StringMap,
			Map,
			Grid,
			Stack,
			Priority
		}

		public enum CppType
		{
			Void,
			RealType,
			IntType,
			BoolType,
			StringType,
			VecType,
			MatrixType,
			ArrType,
			VarType
		}

		// Copy a DataType
		public DataType(DataType other)
		{
			foreach (Assignment ass in other.Assignments)
				Assignments.Add(new Assignment(ass, ass.Func, ass.Line));
			UpdateCppType();
		}

		// Create a generic type
		public DataType(Type rawType = Type.Unknown)
		{
			if (rawType != Type.Unknown)
				Assignments.Add(new Assignment(rawType, "", null));
			UpdateCppType();
		}

		// Create a reference type
		public DataType(Type rawType, string refId)
		{
			if (rawType != Type.Unknown)
				Assignments.Add(new Assignment(rawType, refId, null));
			UpdateCppType();
		}

		// Create a container type
		public DataType(Type rawType, DataType containerType)
		{
			if (rawType != Type.Unknown)
				Assignments.Add(new Assignment(rawType, "", containerType));
			UpdateCppType();
		}

		// Create a DataType from a text string
		public DataType(string name)
		{
			string[] split = name.Replace(">", "").Split('<');
			Type rawType = Type.Unknown;

			switch (split[0])
			{
				case "unknown": rawType = Type.Unknown; break;
				case "VarType":
				case "VarType&":
				case "const VarType&":
				case "variant": rawType = Type.Variant; break;
				case "null": rawType = Type.Null; break;
				case "void": rawType = Type.Void; break;
				case "BoolType":
				case "bool": rawType = Type.Bool; break;
				case "intorreal": rawType = Type.IntOrReal; break;
				case "IntType":
				case "int": rawType = Type.Integer; break;
				case "RealType":
				case "real": rawType = Type.Real; break;
				case "StringType":
				case "string": rawType = Type.String; break;
				case "reference":
				{
					if (split.Length != 2)
					{
						Console.WriteLine("FATAL ERROR: Missing ID for reference.");
						Environment.Exit(1);
					}
					Assignments.Add(new Assignment(Type.Reference, split[1], null));
					UpdateCppType();
					return;
				}
				case "VecType":
				case "vec": rawType = Type.Vector; break;
				case "MatrixType":
				case "matrix": rawType = Type.Matrix; break;
				case "ArrType":
				case "array": rawType = Type.Array; break;
				case "list": rawType = Type.List; break;
				case "anymap": rawType = Type.AnyMap; break;
				case "intmap": rawType = Type.IntMap; break;
				case "stringmap": rawType = Type.StringMap; break;
				case "map": rawType = Type.Map; break;
				case "grid": rawType = Type.Grid; break;
				case "stack": rawType = Type.Stack;  break;
				case "priority": rawType = Type.Priority; break;
				default:
				{
					Console.WriteLine("FATAL ERROR: Unknown data type: {0}", split[0]);
					Environment.Exit(1);
					break;
				}
			}

			if (rawType >= Type.Array) // Container
			{
				DataType containerType;
				if (rawType != Type.Array && IsRawTypeArray(rawType)) // vec or matrix
					containerType = new DataType(Type.Real);

				else if (split.Length > 1)
				{
					string stringEnd = "";
					for (int i = 1; i < split.Length; i++)
						stringEnd += split[i] + (i < split.Length - 1 ? "<" : "");
					containerType = new DataType(stringEnd);
				}
				else
					containerType = new DataType(Type.Unknown);

				Assignments.Add(new Assignment(rawType, "", containerType));
			}
			else if (rawType != Type.Unknown)
				Assignments.Add(new Assignment(rawType, "", null));

			UpdateCppType();
		}

		// Update the C++ type.
		public void UpdateCppType()
		{
			// Update C++ type
			bool isSet = false;
			foreach (Assignment ass in Assignments)
			{
				CppType assType = CppType.VarType;
				switch (ass.RawType)
				{
					case Type.Variant: assType = CppType.VarType; break;
					case Type.Null: assType = CppType.IntType; break;
					case Type.Void: assType = CppType.Void; break;
					case Type.Bool: assType = CppType.BoolType; break;
					case Type.Integer: assType = CppType.IntType; break;
					case Type.Real:
					case Type.IntOrReal: assType = CppType.RealType; break;
					case Type.String: assType = CppType.StringType; break;
					case Type.Reference: assType = CppType.IntType; break; // TODO pointers?
					case Type.Array: assType = CppType.ArrType; break;
					case Type.Vector: assType = CppType.VecType; break;
					case Type.Matrix: assType = CppType.MatrixType; break;
					case Type.List:
					case Type.AnyMap:
					case Type.IntMap:
					case Type.StringMap:
					case Type.Map:
					case Type.Grid:
					case Type.Stack:
					case Type.Priority: assType = CppType.IntType; break;
				}

				if (!isSet)
				{
					cppType = assType;
					isSet = true;
				}
				else if (cppType != assType)
				{
					cppType = CppType.VarType;
					return;
				}
			}
		}

		// Returns the C++ struct of the type.
		public string ToCpp()
		{
			if (AllVarType && !IgnoreAllVarType && cppType != CppType.Void)
				return "VarType";

			switch (cppType)
			{
				case CppType.Void: return "void";
				case CppType.RealType: return "RealType";
				case CppType.IntType: return "IntType";
				case CppType.BoolType: return "BoolType";
				case CppType.StringType: return "StringType";
				case CppType.VecType: return "VecType";
				case CppType.MatrixType: return "MatrixType";
				case CppType.ArrType: return "ArrType";
				case CppType.VarType: return "VarType";
			}
			return "";
		}


		// Converts the type to a C++ member macro.
		public string ToCppMemberMacro()
		{
			switch (cppType)
			{
				case CppType.RealType: return "Real";
				case CppType.IntType: return "Int";
				case CppType.BoolType: return "Bool";
				case CppType.StringType: return "Str";
				case CppType.VecType: return "Vec";
				case CppType.MatrixType: return "Mat";
				case CppType.ArrType: return "Arr";
				case CppType.VarType: return "Var";
			}
			return "";
		}

		// Converts the type to a default value in C++.
		public string ToCppDefaultValue()
		{
			switch (cppType)
			{
				case CppType.RealType: return "0.0";
				case CppType.IntType: return "IntType(0)";
				case CppType.BoolType: return "false";
				case CppType.StringType: return "\"\"";
				case CppType.VecType: return "VecType()";
				case CppType.MatrixType: return "MatrixType()";
				case CppType.ArrType: return "ArrType()";
				case CppType.VarType: return "VarType()";
			}
			return "";
		}

		// Converts the type to the Type character in C++.
		public string ToCppEnum()
		{
			switch (cppType)
			{
				case CppType.RealType: return "REAL_t";
				case CppType.IntType: return "INTEGER_t";
				case CppType.BoolType: return "BOOLEAN_t";
				case CppType.StringType: return "STRING_t";
				case CppType.VecType: return "VECTOR_t";
				case CppType.MatrixType: return "MATRIX_t";
				case CppType.ArrType: return "ARRAY_t";
				case CppType.VarType: return "VARIANT_t";
			}
			return "";
		}

		// Returns whether the type is a C++ VarType.
		public bool IsCppVarType()
		{
			return cppType == CppType.VarType;
		}

		// Returns a string with all type assignments in the project, if more than one.
		public string GetAssignmentsString(string tabs = "")
		{
			string varStr = "";
			foreach (Assignment ass in Assignments)
			{
				varStr += tabs + ass.ToString();
				if (ass.Func != null)
					varStr += " in " + ass.Func.Name + ":" + ass.Line;
				varStr += "\n";
			}
			return varStr;
		}

		// Returns the type in string form with <> for containers/references or "Variant" for multiple types.
		public override string ToString()
		{
			if (Assignments.Count == 0)
				return "Unknown";

			string str = "";
			for (int i = 0; i < Assignments.Count; i++)
				str += (i > 0 ? ", " : "") + Assignments[i].ToString();

			return str;
		}

		// Returns whether the type has not been assigned any raw type.
		public bool IsUnknown()
		{
			return (Assignments.Count == 0);
		}

		// Returns whether the given raw type is a real number.
		static public bool IsRawTypeReal(Type type)
		{
			return (type == Type.IntOrReal ||
					type == Type.Real ||
					type == Type.Integer ||
					type == Type.Bool);
		}

		// Returns whether the given raw type is accessed using [i] or [@i].
		static public bool IsRawTypeArray(Type type)
		{
			return (type == Type.Array || 
					type == Type.Vector ||
					type == Type.Matrix);
		}

		// Returns whether the given raw type is a map.
		static public bool IsRawTypeMap(Type type)
		{
			return (type == Type.AnyMap || 
					type == Type.Map ||
					type == Type.IntMap ||
					type == Type.StringMap);
		}

		// Returns whether the type has been assigned a real number.
		public bool IsReal()
		{
			if (Assignments.Count == 0)
				return false;

			foreach (Assignment ass in Assignments)
				if (IsRawTypeReal(ass.RawType))
					return true;

			return false;
		}

		// Returns whether the type can store other types and use the [] operator.
		public bool IsContainer()
		{
			foreach (Assignment ass in Assignments)
				if (ass.RawType >= Type.Array)
					return true;
			
			return false;
		}

		// Returns the first assignment that matches the raw type, or null if not found.
		public Assignment GetFirstAssignment(Type rawType = Type.Unknown)
		{
			foreach (Assignment ass in Assignments)
				if (rawType == Type.Unknown ||
					ass.RawType == rawType ||
					(rawType == Type.AnyMap && IsRawTypeMap(ass.RawType)))
					return ass;

			return null;
		}

		// Returns all assignments that matches the raw type.
		public List<Assignment> GetAssignments(Type rawType = Type.Unknown)
		{
			List<Assignment> result = new List<Assignment>();
			foreach (Assignment ass in Assignments)
				if (rawType == Type.Unknown || ass.RawType == rawType)
					result.Add(ass);

			return result;
		}

		// Returns an unique object reference id assigned to the type, or empty string if not found.
		public string GetUniqueReferenceId()
		{
			string refId = "";
			bool isSet = false;
			foreach (Assignment ass in Assignments)
			{
				if (ass.RawType == Type.Reference)
				{
					if (isSet) // Multiple assignments found containing references, exit "any"
						return "any";
					
					refId = ass.RefId;
					isSet = true;
				}
			}

			return refId;
		}

		// Returns the map type of the datatype.
		public Type GetMapType()
		{
			foreach (Assignment ass in Assignments)
				if (IsRawTypeMap(ass.RawType))
					return ass.RawType;

			return Type.Unknown;
		}

		// Assign another DataType class to this one. Returns whether the type was updated.
		public bool Assign(DataType inputType, Function func, int line, int containerLevel = 0)
		{
			const int maxContainerLevel = 1;

			if (inputType == null || inputType.Assignments.Count == 0) // Unknown input
				return false;

			bool changed = false;
			foreach (Assignment inputAss in inputType.Assignments) // Iterate input assignments
			{
				bool addNew = true;
				foreach (Assignment ass in Assignments) // Combine/Add assignments
				{
					Type inputRawType = inputAss.RawType;
					if ((IsRawTypeReal(ass.RawType) && IsRawTypeReal(inputRawType)) || // Both real
						(IsRawTypeArray(ass.RawType) && IsRawTypeArray(inputRawType))) // Both array
					{
						addNew = false;
						if (inputRawType > ass.RawType) // Overwrite if larger
						{
							ass.RawType = inputRawType;
							changed = true;
							ass.Func = func;
							ass.Line = line;
						}
					}
					else if (inputRawType == Type.Reference && ass.RawType == Type.Reference) // Both reference
					{
						if (ass.RefId == "" && inputAss.RefId != "") // Unknown reference
						{
							ass.RefId = inputAss.RefId;
							changed = true;
							ass.Func = func;
							ass.Line = line;
							addNew = false; 
						}
						else if (inputAss.RefId == ass.RefId) // Empty input/Same object
							addNew = false;
					}
					else if (IsRawTypeMap(ass.RawType) && IsRawTypeMap(inputRawType) && inputRawType != ass.RawType) // Both map
					{
						addNew = false;
						if (inputRawType > ass.RawType) // Overwrite if larger
						{
							if (ass.RawType == Type.IntMap) // StringMap + IntMap -> Map
								ass.RawType = Type.Map;
							else
								ass.RawType = inputRawType;
							changed = true;
							ass.Func = func;
							ass.Line = line;
						}
					}
					else if (ass.RawType == inputRawType) // Type match
						addNew = false;

					// Assign container
					if ((ass.RawType == Type.Array || ass.RawType >= Type.List) &&
						inputAss.ContainerType != null && containerLevel < maxContainerLevel &&
						ass.ContainerType.Assign(inputAss.ContainerType, func, line, containerLevel + 1))
					{
						changed = true;
						ass.Func = func;
						ass.Line = line;
					}

					if (!addNew)
						break;
				}

				// Other assignment is unique, add a copy to this type
				if (addNew)
				{
					Assignments.Add(new Assignment(inputAss, func, line));
					changed = true;
				}
			}

			if (changed)
				UpdateCppType();

			return changed;
		}
	}
}
