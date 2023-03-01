#pragma once
#include "Asset.hpp"

#include "Type/ArrType.hpp"

namespace CppProject
{
	// Script asset with a lambda for script_execute support.
	struct Script : Asset
	{
		Script(QString name, IntType subAssetId, function<VarType(IntType, IntType, VarArgs)> func);

		// Executes the script with the given arguments.
		VarType Execute(IntType selfId, IntType otherId, VarArgs args) { return execFunc(selfId, otherId, args); }

		function<VarType(IntType, IntType, VarArgs)> execFunc; // Runs the script with the given arguments, returning an optional VarType
	};
}