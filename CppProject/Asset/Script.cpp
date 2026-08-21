#include "Script.hpp"

namespace CppProject
{
	Script::Script(QString name, IntType subAssetId, ExecuteFunction func) : Asset(ID_Script, subAssetId, name), execFunc(func) {}
}
