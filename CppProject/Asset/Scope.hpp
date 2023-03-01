#pragma once
#include "Object.hpp"

#define noone -4

namespace CppProject
{
	// An execution scope for the converted scripts, used in non-global functions and allows the "self" keyword.
	// The scope starts off as Scope<obj> in the constructors but can change using with() statements.
	// In methods using Scope<T>, self->var can be used to access members.
	template <typename T> struct Scope
	{
		Scope(T* object, IntType otherId = noone) :
			object(object), otherId(otherId)
		{}

		Scope(IntType id, IntType otherId = noone) :
			object(Asset::Find<T>(id, ID_Object, 0, false)), otherId(otherId)
		{}

		template <typename O> Scope(const Scope<O>& scope) :
			object((T*)scope.object), otherId(scope.otherId)
		{}

		// Initialize a Scope with a list of objects to iterate through.
		Scope(QVector<IntType> objIds, IntType otherId = noone) :
			objIds(objIds), otherId(otherId)
		{
			NextObject();
		}

		// Allows self->var instead of self->object->var.
		T* operator->() { return object; }

		// Iterate to the next object, sets object to nullptr if no more are found.
		void NextObject()
		{
			object = nullptr;
			while (objIdsIt < objIds.size()) // Find next non-destroyed object
				if (object = Asset::Find<T>(objIds[objIdsIt++], ID_Object, 0, false))
					break;
		}

		// Clear the scope by setting the object to nullptr.
		void Clear()
		{
			object = nullptr;
			otherId = noone;
		}

		// Returns whether the scope has a valid object.
		bool IsValid() const
		{
			return object != nullptr;
		}

		T* object = nullptr;
		IntType otherId;
		QVector<IntType> objIds;
		IntType objIdsIt = 0;
	};

	// An unknown scope, "self" can evaluate to any Object pointer.
	struct ScopeAny : Scope<Object>
	{
		ScopeAny(IntType id, IntType otherId = noone) :
			Scope(ObjOpt(id), otherId)
		{}

		template <typename O> ScopeAny(const Scope<O>& scope) :
			Scope((Object*)scope.object, scope.otherId)
		{}
	};
}
