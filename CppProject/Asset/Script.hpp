#pragma once
#include "Asset.hpp"

#include "Type/ArrType.hpp"

namespace CppProject
{
	// Script asset with a lambda for script_execute support.
	struct Script : Asset
	{
		using ExecuteFunction = VarType (*)(IntType, IntType, VarArgs);

		Script(QString name, IntType subAssetId, ExecuteFunction func);

		// Executes the script with the given arguments.
		VarType Execute(IntType selfId, IntType otherId, VarArgs args) { return execFunc(selfId, otherId, args); }

		ExecuteFunction execFunc; // Runs the script with the given arguments, returning an optional VarType
	};
}
