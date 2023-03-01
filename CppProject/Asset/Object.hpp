#pragma once
#include "Asset.hpp"
#include "Type/VecType.hpp"
#include "Type/ArrType.hpp"
#include "Type/MatrixType.hpp"
#include "Type/VarType.hpp"
#include "DataStructure.hpp"

// Get an Object from an instance id
#define Obj(id) FindAssetReq(Object, id)
#define ObjOpt(id) FindAssetOpt(Object, id)
#define ObjType(type, id) FindSubAssetReq(type, Object, id)
#define ObjTypeOpt(type, id) FindSubAssetOpt(type, Object, id)

// Access memory locations in the Object of the current scope
#define sReal(memberId) self->GetRealRef(M_##memberId)
#define sInt(memberId) self->GetIntRef(M_##memberId)
#define sBool(memberId) self->GetBoolRef(M_##memberId)
#define sStr(memberId) self->GetStrRef(M_##memberId)
#define sVec(memberId) self->GetVecRef(M_##memberId)
#define sMat(memberId) self->GetMatRef(M_##memberId)
#define sArr(memberId) self->GetArrRef(M_##memberId)
#define sVar(memberId) self->GetVarRef(M_##memberId)

// Access memory locations in an Object from an ID
#define idReal(id, memberId) Obj(id)->GetRealRef(M_##memberId)
#define idInt(id, memberId) Obj(id)->GetIntRef(M_##memberId)
#define idBool(id, memberId) Obj(id)->GetBoolRef(M_##memberId)
#define idStr(id, memberId) Obj(id)->GetStrRef(M_##memberId)
#define idVec(id, memberId) Obj(id)->GetVecRef(M_##memberId)
#define idMat(id, memberId) Obj(id)->GetMatRef(M_##memberId)
#define idArr(id, memberId) Obj(id)->GetArrRef(M_##memberId)
#define idVar(id, memberId) Obj(id)->GetVarRef(M_##memberId)
#define idFunc(id, funcId) Obj(id)->GetInstanceFunc(M_##funcId)

namespace CppProject
{
	// GameMaker object
	struct Object : Asset
	{
		// Returns a list IDs of all objects with a given sub-asset id.
		static const QVector<IntType>& GetAll(IntType subAssetId) { return objectIdsMap[subAssetId]; }

		// Store memory locations of members within the object when the first instance is created.
		virtual void InitMembers() = 0;

		// Gets a member reference in the object, if it doesn't exist in the struct it is dynamically created as
		// VarType with a given type. An exception is thrown if it exists in another type than expected (in struct or map).
		RealType& GetRealRef(IntType memberId);
		IntType& GetIntRef(IntType memberId);
		BoolType& GetBoolRef(IntType memberId);
		StringType& GetStrRef(IntType memberId);
		VecType& GetVecRef(IntType memberId);
		MatrixType& GetMatRef(IntType memberId);
		ArrType& GetArrRef(IntType memberId);
		VarType& GetVarRef(IntType memberId);
		function<VarType(VarArgs)>& GetInstanceFunc(IntType funcId);

		// Type and memory offset of a member relative to the "this" pointer.
		struct Member
		{
			Type type = UNDEFINED_t;
			long long memoryOffset = 0;
		};

		static QHash<IntType, QVector<IntType>> objectIdsMap; // Maps a sub-asset id to a list of object ids
		static QHash<IntType, QHash<IntType, Member>> memberMap; // Maps a sub-asset id to a mapping of member ids to memory offsets
		QHash<IntType, function<VarType(VarArgs)>> instanceFuncMap; // Maps an instance function id to a lambda taking VarArgs arguments, returning VarType

		virtual ~Object();

	protected:
		Object(QString name, IntType subAssetId);
		QHash<IntType, Member>* memMap = nullptr;
		QHash<IntType, function<VarType(VarArgs)>>* funcMap = nullptr;
		QHash<IntType, VarType> dynamicMemberMap; // Maps member ids to VarTypes that are created in runtime
	};
}