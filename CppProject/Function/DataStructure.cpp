#include "Generated/Scripts.hpp"

#include "Asset/DataStructure.hpp"

namespace CppProject
{
	BoolType ds_list_valid(VarType id)
	{
		if (!id.IsAnyReal())
			return false;
		return (FindList(id) != nullptr);
	}

	BoolType ds_map_valid(VarType id)
	{
		if (!id.IsAnyReal())
			return false;
		return (FindMap(id) != nullptr);
	}

	IntType ds_string_map_create()
	{
		return (new StringHashMap())->id;
	}

	IntType ds_int_map_create()
	{
		return (new IntHashMap())->id;
	}
}
