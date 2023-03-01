#include "Generated/GmlFunc.hpp"

#include "Asset/DataStructure.hpp"

namespace CppProject
{
	BoolType ds_exists(VarType id, IntType type)
	{
		IntType dsId = id;
		switch (type)
		{
			case ds_type_map: return (FindMap(dsId) != nullptr);
			case ds_type_list: return (FindList(dsId) != nullptr);
			case ds_type_stack: return (FindStack(dsId) != nullptr);
			case ds_type_priority: return (FindPriority(dsId) != nullptr);
		}

		return false;
	}

	void ds_grid_clear(IntType id, VarType value)
	{
		// Unused
	}

	IntType ds_grid_create(IntType, IntType)
	{
		// Unused
		return 0;
	}

	void ds_grid_destroy(IntType id)
	{
		// Unused
	}

	VarType ds_grid_get(IntType id, IntType x, IntType y)
	{
		// Unused
		return VarType();
	}

	void ds_grid_set(IntType id, IntType x, IntType y, VarType value)
	{
		// Unused
	}

	void ds_list_add(VarArgs args)
	{
		if (args.Size() < 2)
			return;

		// Add new array element with { value, 0 }
		if (List* list = FindList(args[0]))
			for (IntType i = 1; i < args.Size(); i++)
				list->vec.append({ args[i], 0 });
	}

	void ds_list_clear(IntType id)
	{
		if (List* list = FindList(id))
			list->Clear();
	}

	void ds_list_copy(IntType idTo, IntType idFrom)
	{
		List* listTo = FindList(idTo);
		List* listFrom = FindList(idFrom);
		if (listTo && listFrom)
			listTo->vec = listFrom->vec;
	}

	IntType ds_list_create()
	{
		return (new List())->id;
	}

	void ds_list_delete(IntType id, IntType index)
	{
		if (List* list = FindList(id))
			list->vec.removeAt(index);
	}

	void ds_list_destroy(IntType id)
	{
		if (List* list = FindList(id))
			delete list;
	}

	BoolType ds_list_empty(IntType id)
	{
		if (List* list = FindList(id))
			return (list->vec.size() == 0);

		return false;
	}

	IntType ds_list_find_index(IntType id, VarType value)
	{
		IntType i = 0;
		if (List* list = FindList(id))
			for (auto it = list->vec.begin(); it != list->vec.end(); it++, i++)
				if (it->value == value)
					return i;

		return -1;
	}

	VarType ds_list_find_value(IntType id, IntType index)
	{
		if (List* list = FindList(id))
			return list->Value(index);

		return VarType();
	}

	void ds_list_insert(IntType id, IntType index, VarType value)
	{
		if (List* list = FindList(id))
			list->vec.insert(std::min((IntType)list->vec.size(), index), { value, 0 });
	}

	IntType ds_list_mark_as_list(IntType id, IntType index)
	{
		if (List* list = FindList(id))
		{
			// Set the dsType at the index, if value is a valid list id
			const VarType& val = (*list)[index];
			if (!ds_exists(val, ds_type_list))
				return -1;

			list->vec[index].dsType = ds_type_list;
			return val;
		}

		return -1;
	}

	IntType ds_list_mark_as_map(IntType id, IntType index)
	{
		if (List* list = FindList(id))
		{
			// Set the dsType at the index, if value is a valid map id
			const VarType& val = (*list)[index];
			if (!ds_exists(val, ds_type_map))
				return -1;

			list->vec[index].dsType = ds_type_map;
			return val;
		}

		return -1;
	}

	IntType ds_list_size(IntType id)
	{
		if (List* list = FindList(id))
			return list->vec.size();

		return 0;
	}

	void ds_list_sort(IntType id, BoolType ascending)
	{
		if (List* list = FindList(id))
			std::sort(list->vec.begin(), list->vec.end(), [ascending](const List::ListValue& v1, const List::ListValue& v2)
			{
				if (v1.value.IsString()) // Sort alphabetically
					return ascending ?
						v1.value.Str().QStr() < v2.value.Str().QStr() :
						v1.value.Str().QStr() > v2.value.Str().QStr();
				else
					return ascending ?
						v1.value < v2.value :
						v1.value > v2.value;
			});
	}

	void ds_map_add_list(IntType id, VarType key, IntType listId)
	{
		if (Map* map = FindMap(id))
			if (ds_exists(listId, ds_type_list))
				map->Set(key, { listId, ds_type_list });
	}

	void ds_map_add_map(IntType id, VarType key, IntType mapId)
	{
		if (Map* map = FindMap(id))
			if (ds_exists(mapId, ds_type_map))
				map->Set(key, { mapId, ds_type_map });
	}

	BoolType ds_map_add(IntType id, VarType key, VarType value)
	{
		if (Map* map = FindMap(id))
			if (!map->Contains(key))
				map->Set(key, { value, 0 });

		return false;
	}

	void ds_map_clear(IntType id)
	{
		if (Map* map = FindMap(id))
			map->Clear();
	}

	void ds_map_copy(IntType idTo, IntType idFrom)
	{
		Map* mapTo = FindMap(idTo);
		Map* mapFrom = FindMap(idFrom);
		if (mapTo && mapFrom)
			mapFrom->Copy(mapTo);
	}

	IntType ds_map_create()
	{
		return (new Map())->id;
	}

	void ds_map_delete(IntType id, VarType key)
	{
		if (Map* map = FindMap(id))
			map->Remove(key);
	}

	void ds_map_destroy(IntType id)
	{
		if (Map* map = FindMap(id))
			delete map;
	}

	BoolType ds_map_exists(IntType id, VarType key)
	{
		if (Map* map = FindMap(id))
			return map->Contains(key);

		return false;
	}

	VarType ds_map_find_first(IntType id)
	{
		if (Map* map = FindMap(id))
			return map->GetFirstKey();

		return VarType();
	}

	VarType ds_map_find_next(IntType id, VarType key)
	{
		if (Map* map = FindMap(id))
			return map->GetNextKey(key);
		return VarType();
	}

	VarType ds_map_find_value(IntType id, VarType key)
	{
		if (Map* map = FindMap(id))
			return map->Value(key);
		return VarType();
	}

	IntType ds_map_size(IntType id)
	{
		if (Map* map = FindMap(id))
			return map->GetSize();

		return 0;
	}

	void ds_priority_add(IntType id, VarType value, IntType prio)
	{
		if (Priority* priority = FindPriority(id))
			priority->vec.append({ value, prio });
	}

	IntType ds_priority_create()
	{
		return (new Priority())->id;
	}

	VarType ds_priority_delete_max(IntType id)
	{
		if (Priority* priority = FindPriority(id))
		{
			IntType maxId = priority->GetMaxPrioIndex();
			if (maxId < 0)
				return VarType();

			VarType val = priority->vec[maxId].value;
			priority->vec.removeAt(maxId);
			return val;
		}

		return VarType();
	}

	VarType ds_priority_find_max(IntType id)
	{
		if (Priority* priority = FindPriority(id))
		{
			IntType maxId = priority->GetMaxPrioIndex();
			if (maxId >= 0)
				return priority->vec[maxId].value;
		}

		return VarType();
	}

	IntType ds_priority_size(IntType id)
	{
		if (Priority* priority = FindPriority(id))
			return priority->vec.size();

		return 0;
	}

	IntType ds_stack_create()
	{
		return (new Stack())->id;
	}

	void ds_stack_destroy(IntType id)
	{
		if (Stack* stack = FindStack(id))
			delete stack;
	}

	BoolType ds_stack_empty(IntType id)
	{
		if (Stack* stack = FindStack(id))
			return (stack->stack.size() == 0);

		return false;
	}

	VarType ds_stack_pop(IntType id)
	{
		if (Stack* stack = FindStack(id))
		{
			if (stack->stack.size() == 0)
				return VarType();

			return stack->stack.pop();
		}

		return VarType();
	}

	void ds_stack_push(VarArgs args)
	{
		if (args.Size() < 2)
			return;

		if (Stack* stack = FindStack(args[0]))
			for (IntType i = 1 ; i < args.Size(); i++)
				stack->stack.push(args[i]);
	}

	VarType ds_stack_top(IntType id)
	{
		if (Stack* stack = FindStack(id))
			if (stack->stack.size() > 0)
				return stack->stack.top();

		return VarType();
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