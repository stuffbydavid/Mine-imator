#include "Script.hpp"

namespace CppProject
{
	Script::Script(QString name, IntType subAssetId, function<VarType(IntType, IntType, VarArgs)> func) : Asset(ID_Script, subAssetId, name)
	{
		execFunc = func;
	}
}