#include "Object.hpp"

#define GetRefImpl(rawType, enumType, varTypeFunc) \
	if (!memMap) \
		memMap = &memberMap[subAssetId]; \
	const Member& mem = memMap->value(memberId); \
	if (mem.type != UNDEFINED_t) /* Get member from struct memory */ \
	{ \
		if (mem.type != enumType) \
			GetRefError(enumType, mem.type); \
		return *(rawType*)((long long)this + (long long)mem.memoryOffset); \
	} \
	else /* Create/get member from dynamic map */ \
	{ \
		VarType& dynMem = dynamicMemberMap[memberId]; \
		Type dynType = dynMem.GetType(); \
		if (dynType != UNDEFINED_t && dynType != enumType && enumType != VARIANT_t) \
			GetRefError(enumType, dynType); \
		return dynMem.varTypeFunc(); \
	}

#define GetRefError(expected, actual) \
	FATAL("Unexpected variable type (expected " + TypeName(expected) + ", actual: " + TypeName(actual) + ")");

namespace CppProject
{
	QHash<IntType, QVector<IntType>> Object::objectIdsMap;
	QHash<IntType, QHash<IntType, Object::Member>> Object::memberMap;

	Object::Object(QString name, IntType subAssetId) :
		Asset(ID_Object, subAssetId, name)
	{
		objectIdsMap[subAssetId].insert(0, id);
	};

	Object::~Object()
	{
		objectIdsMap[subAssetId].removeOne(id);
	}

	RealType& Object::GetRealRef(IntType memberId)
	{
		GetRefImpl(RealType, REAL_t, Real);
	}

	IntType& Object::GetIntRef(IntType memberId)
	{
		GetRefImpl(IntType, INTEGER_t, Int);
	}

	BoolType& Object::GetBoolRef(IntType memberId)
	{
		GetRefImpl(BoolType, BOOLEAN_t, Bool);
	}

	StringType& Object::GetStrRef(IntType memberId)
	{
		GetRefImpl(StringType, STRING_t, Str);
	}

	VecType& Object::GetVecRef(IntType memberId)
	{
		GetRefImpl(VecType, VECTOR_t, Vec);
	}

	MatrixType& Object::GetMatRef(IntType memberId)
	{
		GetRefImpl(MatrixType, MATRIX_t, Mat);
	}

	ArrType& Object::GetArrRef(IntType memberId)
	{
		GetRefImpl(ArrType, ARRAY_t, Arr);
	}

	VarType& Object::GetVarRef(IntType memberId)
	{
		GetRefImpl(VarType, VARIANT_t, Var);
	}

	function<VarType(VarArgs)>& Object::GetInstanceFunc(IntType funcId)
	{
		if (!instanceFuncMap.contains(funcId))
			FATAL("Call to unknown function " + NumStr(funcId));

		return instanceFuncMap[funcId];
	}
}