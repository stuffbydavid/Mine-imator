#include "DataStructure.hpp"

#include "Generated/GmlFunc.hpp"

namespace CppProject
{
	List::~List()
	{
		Clear();
	}

	VarType& List::operator[](IntType index)
	{
		if (index < 0) // Invalid index
			FATAL("List: Attempting to access negative index " + NumStr(index));

		IntType sz = vec.size();
		if (index >= sz) // Resize vector
			for (int i = sz; i <= index; i++)
				vec.append({ VarType(), 0 });

		return vec[index].value;
	}

	const VarType& List::Value(IntType index) const
	{
		if (index < 0 || index >= vec.size()) // Invalid index, undefined
			return VarArgs::outOfBounds;

		return vec.at(index).value;
	}

	void List::Clear()
	{
		// Clear datastructures referenced by the list
		for (auto it = vec.begin(); it != vec.end(); it++)
		{
			if (it->dsType == ds_type_list)
				delete FindList(it->value.ToInt());
			else if (it->dsType == ds_type_map)
				delete FindList(it->value.ToInt());
		}
		vec.clear();
	}

	void List::Debug() const
	{
		IntType i = 0;
		for (auto it = vec.begin(); it != vec.end(); it++, i++)
		{
			QString line = NumStr(i) + ": " + it->value.ToStr();

			if (it->dsType == ds_type_list)
			{
				DEBUG(line + " [List]");
				Printer::indent++;
				if (List* list = FindList(it->value.ToInt()))
					list->Debug();
				Printer::indent--;
			}
			else if (it->dsType == ds_type_map)
			{
				DEBUG(line + " [Map]");
				Printer::indent++;
				if (Map* map = FindMap(it->value.ToInt()))
					map->Debug();
				Printer::indent--;
			}
			else
			{
				DEBUG(line + " [" + TypeName(it->value.GetType()) + "]");
				it->value.Debug();
			}
		}
	}

	IntType Priority::GetMaxPrioIndex() const
	{
		if (vec.size() == 0)
			return -1;

		IntType maxPrio = 0, maxId = 0, i = 0;
		for (auto it = vec.begin(); it != vec.end(); it++, i++)
		{
			if (it->prio > maxPrio)
			{
				maxPrio = it->prio;
				maxId = i;
			}
		}
		return maxId;
	}
}