#include "CppGen.hpp"

namespace CppGen
{
DataType::CppType cppTypeFor(DataType::Type rawType)
{
	switch (rawType)
	{
		case DataType::Type::Void: return DataType::CppType::Void;
		case DataType::Type::Real:
		case DataType::Type::IntOrReal: return DataType::CppType::RealType;
		case DataType::Type::Null:
		case DataType::Type::Integer:
		case DataType::Type::Reference:
		case DataType::Type::List:
		case DataType::Type::AnyMap:
		case DataType::Type::IntMap:
		case DataType::Type::StringMap:
		case DataType::Type::Map:
		case DataType::Type::Grid:
		case DataType::Type::Stack:
		case DataType::Type::Priority: return DataType::CppType::IntType;
		case DataType::Type::Bool: return DataType::CppType::BoolType;
		case DataType::Type::String: return DataType::CppType::StringType;
		case DataType::Type::Vector: return DataType::CppType::VecType;
		case DataType::Type::Matrix: return DataType::CppType::MatrixType;
		case DataType::Type::Array: return DataType::CppType::ArrType;
		case DataType::Type::Unknown:
		case DataType::Type::Variant: return DataType::CppType::VarType;
	}

	return DataType::CppType::VarType;
}

DataType::DataType(Type rawType)
{
	if (rawType != Type::Unknown)
		this->assignments.emplace_back(rawType, "", nullptr);
	updateCppType();
}

DataType::DataType(Type rawType, String refId)
{
	if (rawType != Type::Unknown)
		this->assignments.emplace_back(rawType, refId, nullptr);
	updateCppType();
}

DataType::DataType(Type rawType, const DataType* containerType)
{
	if (rawType != Type::Unknown)
		this->assignments.emplace_back(rawType, "", containerType);
	updateCppType();
}

DataType::DataType(String name)
{
	List<String> split = name.replace(">", "").split('<');
	Type rawType = Type::Unknown;

	if (split[0] == "unknown")
	{
		rawType = Type::Unknown;
	}
	else if (split[0] == "VarType" || split[0] == "VarType&" || split[0] == "const VarType&" || split[0] == "variant")
	{
		rawType = Type::Variant;
	}
	else if (split[0] == "null")
	{
		rawType = Type::Null;
	}
	else if (split[0] == "void")
	{
		rawType = Type::Void;
	}
	else if (split[0] == "BoolType" || split[0] == "bool")
	{
		rawType = Type::Bool;
	}
	else if (split[0] == "intorreal")
	{
		rawType = Type::IntOrReal;
	}
	else if (split[0] == "IntType" || split[0] == "int")
	{
		rawType = Type::Integer;
	}
	else if (split[0] == "RealType" || split[0] == "real")
	{
		rawType = Type::Real;
	}
	else if (split[0] == "StringType" || split[0] == "string")
	{
		rawType = Type::String;
	}
	else if (split[0] == "reference")
	{
		{
			if (split.size() != 2)
			{
				Console::writeLine("FATAL ERROR: Missing ID for reference.");
				Environment::exit(1);
			}
			this->assignments.emplace_back(Type::Reference, split[1], nullptr);
			updateCppType();
			return;
		}
	}
	else if (split[0] == "VecType" || split[0] == "vec")
	{
		rawType = Type::Vector;
	}
	else if (split[0] == "MatrixType" || split[0] == "matrix")
	{
		rawType = Type::Matrix;
	}
	else if (split[0] == "ArrType" || split[0] == "array")
	{
		rawType = Type::Array;
	}
	else if (split[0] == "list")
	{
		rawType = Type::List;
	}
	else if (split[0] == "anymap")
	{
		rawType = Type::AnyMap;
	}
	else if (split[0] == "intmap")
	{
		rawType = Type::IntMap;
	}
	else if (split[0] == "stringmap")
	{
		rawType = Type::StringMap;
	}
	else if (split[0] == "map")
	{
		rawType = Type::Map;
	}
	else if (split[0] == "grid")
	{
		rawType = Type::Grid;
	}
	else if (split[0] == "stack")
	{
		rawType = Type::Stack;
	}
	else if (split[0] == "priority")
	{
		rawType = Type::Priority;
	}
	else
	{
		{
			Console::writeLine("FATAL ERROR: Unknown data type: {0}", split[0]);
			Environment::exit(1);

		}
	}

	if (rawType >= Type::Array) // Container
	{
		DataType containerType;
		if (rawType != Type::Array && isRawTypeArray(rawType)) // vec or matrix
			containerType.reset(Type::Real);

		else if (split.size() > 1)
		{
			String stringEnd = "";
			for (int i = 1; i < static_cast<int>(split.size()); i++)
				stringEnd += split[i] + (i < static_cast<int>(split.size()) - 1 ? "<" : "");
			containerType = DataType(stringEnd);
		}
		else
			containerType.reset(Type::Unknown);

		this->assignments.emplace_back(rawType, "", &containerType);
	}
	else if (rawType != Type::Unknown)
		this->assignments.emplace_back(rawType, "", nullptr);

	updateCppType();
}

void DataType::updateCppType()
{
	// Update C++ type
	bool isSet = false;
	for (const Assignment& ass : this->assignments)
	{
		const CppType assType = cppTypeFor(ass.rawType);

		if (!isSet)
		{
			cppType = assType;
			isSet = true;
		}
		else if (cppType != assType)
		{
			cppType = CppType::VarType;
			return;
		}
	}
}

String DataType::toCpp()
{
	if (DataType::allVarType && !DataType::ignoreAllVarType && cppType != CppType::Void)
		return "VarType";

	switch (cppType)
	{
		case CppType::Void: return "void";
		case CppType::RealType: return "RealType";
		case CppType::IntType: return "IntType";
		case CppType::BoolType: return "BoolType";
		case CppType::StringType: return "StringType";
		case CppType::VecType: return "VecType";
		case CppType::MatrixType: return "MatrixType";
		case CppType::ArrType: return "ArrType";
		case CppType::VarType: return "VarType";
	}
	return "";
}

String DataType::toCppMemberMacro()
{
	switch (cppType)
	{
		case CppType::Void: return "";
		case CppType::RealType: return "Real";
		case CppType::IntType: return "Int";
		case CppType::BoolType: return "Bool";
		case CppType::StringType: return "Str";
		case CppType::VecType: return "Vec";
		case CppType::MatrixType: return "Mat";
		case CppType::ArrType: return "Arr";
		case CppType::VarType: return "Var";
	}
	return "";
}

String DataType::toCppDefaultValue()
{
	switch (cppType)
	{
		case CppType::Void: return "";
		case CppType::RealType: return "0.0";
		case CppType::IntType: return "IntType(0)";
		case CppType::BoolType: return "false";
		case CppType::StringType: return "\"\"";
		case CppType::VecType: return "VecType()";
		case CppType::MatrixType: return "MatrixType()";
		case CppType::ArrType: return "ArrType()";
		case CppType::VarType: return "VarType()";
	}
	return "";
}

String DataType::toCppEnum()
{
	switch (cppType)
	{
		case CppType::Void: return "";
		case CppType::RealType: return "REAL_t";
		case CppType::IntType: return "INTEGER_t";
		case CppType::BoolType: return "BOOLEAN_t";
		case CppType::StringType: return "STRING_t";
		case CppType::VecType: return "VECTOR_t";
		case CppType::MatrixType: return "MATRIX_t";
		case CppType::ArrType: return "ARRAY_t";
		case CppType::VarType: return "VARIANT_t";
	}
	return "";
}

bool DataType::isCppVarType()
{
	return cppType == CppType::VarType;
}

String DataType::getAssignmentsString(String tabs)
{
	String varStr = "";
	for (Assignment& ass : this->assignments)
	{
		varStr += tabs + ass.toString();
		if (ass.func != nullptr)
			varStr += " in " + ass.func->name + ":" + ass.line;
		varStr += "\n";
	}
	return varStr;
}

String DataType::toString()
{
	if (this->assignments.size() == 0)
		return "Unknown";

	String str = "";
	for (int i = 0; i < static_cast<int>(this->assignments.size()); i++)
		str += (i > 0 ? ", " : "") + this->assignments[i].toString();

	return str;
}

bool DataType::isUnknown()
{
	return (this->assignments.size() == 0);
}

bool DataType::isRawTypeReal(Type type)
{
	return (type == Type::IntOrReal ||
			type == Type::Real ||
			type == Type::Integer ||
			type == Type::Bool);
}

bool DataType::isRawTypeArray(Type type)
{
	return (type == Type::Array ||
			type == Type::Vector ||
			type == Type::Matrix);
}

bool DataType::isRawTypeMap(Type type)
{
	return (type == Type::AnyMap ||
			type == Type::Map ||
			type == Type::IntMap ||
			type == Type::StringMap);
}

String DataType::typeName(Type rawType)
{
	switch (rawType)
	{
		case Type::Unknown: return "Unknown";
		case Type::Variant: return "Variant";
		case Type::Null: return "Null";
		case Type::Void: return "Void";
		case Type::Bool: return "Bool";
		case Type::IntOrReal: return "IntOrReal";
		case Type::Integer: return "Integer";
		case Type::Real: return "Real";
		case Type::String: return "String";
		case Type::Reference: return "Reference";
		case Type::Array: return "Array";
		case Type::Vector: return "Vector";
		case Type::Matrix: return "Matrix";
		case Type::List: return "List";
		case Type::AnyMap: return "AnyMap";
		case Type::IntMap: return "IntMap";
		case Type::StringMap: return "StringMap";
		case Type::Map: return "Map";
		case Type::Grid: return "Grid";
		case Type::Stack: return "Stack";
		case Type::Priority: return "Priority";
	}

	return "Unknown";
}

const DataType& DataType::scalar(Type rawType)
{
	static const std::array<DataType, static_cast<std::size_t>(Type::Priority) + 1> types = []
	{
		std::array<DataType, static_cast<std::size_t>(Type::Priority) + 1> result;
		for (std::size_t i = 0; i < result.size(); ++i)
			result[i].reset(static_cast<Type>(i));
		return result;
	}();

	return types[static_cast<std::size_t>(rawType)];
}

bool DataType::isReal()
{
	if (this->assignments.size() == 0)
		return false;

	for (Assignment& ass : this->assignments)
		if (isRawTypeReal(ass.rawType))
			return true;

	return false;
}

bool DataType::isContainer()
{
	for (Assignment& ass : this->assignments)
		if (ass.rawType >= Type::Array)
			return true;

	return false;
}

DataType::Assignment* DataType::getFirstAssignment(Type rawType)
{
	for (Assignment& ass : this->assignments)
		if (rawType == Type::Unknown ||
			ass.rawType == rawType ||
			(rawType == Type::AnyMap && isRawTypeMap(ass.rawType)))
			return &ass;

	return nullptr;
}

List<DataType::Assignment*> DataType::getAssignments(Type rawType)
{
	List<Assignment*> result = List<Assignment*>();
	for (Assignment& ass : this->assignments)
		if (rawType == Type::Unknown || ass.rawType == rawType)
			result.add(&ass);

	return result;
}

String DataType::getUniqueReferenceId()
{
	String refId = "";
	bool isSet = false;
	for (Assignment& ass : this->assignments)
	{
		if (ass.rawType == Type::Reference)
		{
			if (isSet) // Multiple assignments found containing references, exit "any"
				return "any";

			refId = ass.refId;
			isSet = true;
		}
	}

	return refId;
}

DataType::Type DataType::getMapType()
{
	for (Assignment& ass : this->assignments)
		if (isRawTypeMap(ass.rawType))
			return ass.rawType;

	return Type::Unknown;
}

bool DataType::assign(const DataType& inputType, Function* func, int line, int containerLevel)
{
	const int maxContainerLevel = 1;

	if (inputType.assignments.size() == 0) // Unknown input
		return false;

	bool changed = false;
	for (const Assignment& inputAss : inputType.assignments) // Iterate input assignments
	{
		bool addNew = true;
		for (Assignment& ass : this->assignments) // Combine/Add assignments
		{
			Type inputRawType = inputAss.rawType;
			if ((isRawTypeReal(ass.rawType) && isRawTypeReal(inputRawType)) || // Both real
				(isRawTypeArray(ass.rawType) && isRawTypeArray(inputRawType))) // Both array
			{
				addNew = false;
				if (inputRawType > ass.rawType) // Overwrite if larger
				{
					ass.rawType = inputRawType;
					changed = true;
					ass.func = func;
					ass.line = line;
				}
			}
			else if (inputRawType == Type::Reference && ass.rawType == Type::Reference) // Both reference
			{
				if (ass.refId == "" && inputAss.refId != "") // Unknown reference
				{
					ass.refId = inputAss.refId;
					changed = true;
					ass.func = func;
					ass.line = line;
					addNew = false;
				}
				else if (inputAss.refId == ass.refId) // Empty input/Same object
					addNew = false;
			}
			else if (isRawTypeMap(ass.rawType) && isRawTypeMap(inputRawType) && inputRawType != ass.rawType) // Both map
			{
				addNew = false;
				if (inputRawType > ass.rawType) // Overwrite if larger
				{
					if (ass.rawType == Type::IntMap) // StringMap + IntMap -> Map
						ass.rawType = Type::Map;
					else
						ass.rawType = inputRawType;
					changed = true;
					ass.func = func;
					ass.line = line;
				}
			}
			else if (ass.rawType == inputRawType) // Type match
				addNew = false;

			// Assign container
			if ((ass.rawType == Type::Array || ass.rawType >= Type::List) &&
				inputAss.containerStorage != nullptr && containerLevel < maxContainerLevel)
			{
				// Assignment copies share their container until one is mutated.
				// This preserves value semantics without deep-copying every resolver
				// temporary and reset.
				if (ass.containerStorage == nullptr || ass.containerStorage.use_count() != 1)
				{
					ass.containerStorage = ass.containerStorage != nullptr
						? std::make_shared<DataType>(*ass.containerStorage)
						: std::make_shared<DataType>();
				}

				if (ass.containerStorage->assign(*inputAss.containerStorage, func, line, containerLevel + 1))
				{
					changed = true;
					ass.func = func;
					ass.line = line;
				}
			}

			if (!addNew)
				break;
		}

		// Other assignment is unique, add a copy to this type
		if (addNew)
		{
			this->assignments.emplace_back(inputAss, func, line);
			changed = true;
		}
	}

	if (changed)
		updateCppType();

	return changed;
}

void DataType::reset(Type rawType)
{
	this->cppType = cppTypeFor(rawType);
	if (rawType == Type::Unknown)
	{
		this->assignments.clear();
	}
	else if (this->assignments.empty())
	{
		this->assignments.emplace_back(rawType, "", nullptr);
	}
	else
	{
		this->assignments.resize(1);
		Assignment& assignment = this->assignments.front();
		assignment.rawType = rawType;
		assignment.refId.clear();
		assignment.containerStorage.reset();
		assignment.func = nullptr;
		assignment.line = 0;
	}
}

void DataType::reset(Type rawType, const String& refId)
{
	this->cppType = cppTypeFor(rawType);
	if (rawType == Type::Unknown)
	{
		this->assignments.clear();
	}
	else if (this->assignments.empty())
	{
		this->assignments.emplace_back(rawType, refId, nullptr);
	}
	else
	{
		this->assignments.resize(1);
		Assignment& assignment = this->assignments.front();
		assignment.rawType = rawType;
		assignment.refId = refId;
		assignment.containerStorage.reset();
		assignment.func = nullptr;
		assignment.line = 0;
	}
}

void DataType::reset(Type rawType, const DataType& containerType)
{
	this->cppType = cppTypeFor(rawType);
	if (rawType == Type::Unknown)
	{
		this->assignments.clear();
	}
	else if (this->assignments.empty())
	{
		this->assignments.emplace_back(rawType, "", &containerType);
	}
	else
	{
		this->assignments.resize(1);
		Assignment& assignment = this->assignments.front();
		assignment.rawType = rawType;
		assignment.refId.clear();
		if (assignment.containerStorage != nullptr && assignment.containerStorage.use_count() == 1)
			assignment.containerStorage->reset(containerType);
		else
			assignment.containerStorage = std::make_shared<DataType>(containerType);
		assignment.func = nullptr;
		assignment.line = 0;
	}
}

void DataType::reset(const DataType& other)
{
	if (this == &other)
		return;

	this->assignments.resize(other.assignments.size());
	for (int i = 0; i < static_cast<int>(other.assignments.size()); i++)
		this->assignments[i] = other.assignments[i];
	this->cppType = other.cppType;
}

DataType::Assignment::Assignment(const DataType::Assignment& other, Function* func, int line)
	: rawType(other.rawType),
	refId(other.refId),
	containerStorage(other.containerStorage),
	func(func),
	line(line)
{
}

DataType::Assignment::Assignment(Type type, String refId, const DataType* containerType, Function* func, int line)
	: rawType(type),
	refId(refId),
	containerStorage(containerType ? std::make_shared<DataType>(*containerType) : nullptr),
	func(func),
	line(line)
{
}

String DataType::Assignment::toString()
{
	if (this->rawType >= Type::Array) // Container
		return DataType::typeName(this->rawType) + "<" + this->containerStorage->toString() + ">";
	else if (this->rawType == Type::Reference) // Reference
		return DataType::typeName(this->rawType) + "<" + this->refId + ">";
	else
		return DataType::typeName(this->rawType);
}

}
