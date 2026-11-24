#include "Object.hpp"
#include "Generated/Scripts.hpp"

#define GetRefError(expected, actual) \
	FATAL("Unexpected variable type (expected " + TypeName(expected) + ", actual: " + TypeName(actual) + ")");

namespace CppProject
{
	QHash<IntType, QVector<IntType>> Object::objectIdsMap;
	QHash<IntType, Object::MemberTable> Object::memberMap;

	BoolType Object::IsIndexed(IntType subAssetId)
	{
		return global::objects_indexed_array.Find(subAssetId) >= 0;
	}

	Object::Object(QString name, IntType subAssetId) :
		Asset(ID_Object, subAssetId, name)
	{
		if (IsIndexed(subAssetId))
			objectIdsMap[subAssetId].append(id);
	};

	Object::~Object()
	{
		if (IsIndexed(subAssetId))
			objectIdsMap[subAssetId].removeOne(id);
	}

	void* Object::GetRefSlow(IntType memberId, Type enumType)
	{
		if (!memMap)
			memMap = &memberMap[subAssetId];

		// Struct member of another type
		const Member mem = memMap->value(memberId);
		if (mem.type != UNDEFINED_t)
		{
			if (mem.type != enumType)
				GetRefError(enumType, mem.type);

			return reinterpret_cast<char*>(this) + mem.memoryOffset;
		}

		// Create/get member from dynamic map
		VarType& dynMem = dynamicMemberMap[memberId];
		Type dynType = dynMem.GetType();
		if (dynType != UNDEFINED_t && dynType != enumType && enumType != VARIANT_t)
			GetRefError(enumType, dynType);

		switch (enumType)
		{
			case REAL_t: return &dynMem.Real();
			case INTEGER_t: return &dynMem.Int();
			case BOOLEAN_t: return &dynMem.Bool();
			case STRING_t: return &dynMem.Str();
			case VECTOR_t: return &dynMem.Vec();
			case MATRIX_t: return &dynMem.Mat();
			case ARRAY_t: return &dynMem.Arr();
			default: return &dynMem.Var();
		}
	}

	function<VarType(VarArgs)>& Object::GetInstanceFunc(IntType funcId)
	{
		if (!instanceFuncMap.contains(funcId))
			FATAL("Call to unknown function " + NumStr(funcId));

		return instanceFuncMap[funcId];
	}
}
