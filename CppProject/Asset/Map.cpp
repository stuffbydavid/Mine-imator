#include "DataStructure.hpp"

#include "Generated/GmlFunc.hpp"

namespace CppProject
{
	Map::~Map()
	{
		deleteAndReset(mapIt);
		Clear();
	}

	VarType Map::Value(const VarType& key) const
	{
		if (!RELEASE_MODE && GetType() != MAP)
			FATAL("Map: Value() const on non-map");

		return map.value(key).value;
	}

	void Map::Copy(Map* to) const
	{
		switch (to->GetType())
		{
			case MAP: to->map = map; break;
			case HASH_STRING:
			{
				if (StringHashMap* toHash = dynamic_cast<StringHashMap*>(to))
				{
					toHash->hash.clear();
					QMapIterator<VarType, MapValue> copyIt(map);
					while (copyIt.hasNext())
					{
						copyIt.next();
						toHash->hash[copyIt.key()] = copyIt.value();
					}
				}
				break;
			}
			case HASH_INT:
			{
				if (IntHashMap* toHash = dynamic_cast<IntHashMap*>(to))
				{
					toHash->hash.clear();
					QMapIterator<VarType, MapValue> copyIt(map);
					while (copyIt.hasNext())
					{
						copyIt.next();
						toHash->hash[copyIt.key()] = copyIt.value();
					}
				}
				break;
			}
		}
	}

	VarType Map::GetFirstKey()
	{
		if (omp_get_thread_num() == 0) // Main thread
		{
			deleteAndReset(mapIt);
			mapIt = new QMapIterator<VarType, Map::MapValue>(map);
			if (mapIt->hasNext())
			{
				mapIt->next();
				return mapIt->key();
			}
		}
		else
		{
			QMapIterator<VarType, Map::MapValue> mapIt(map);
			if (mapIt.hasNext())
			{
				mapIt.next();
				return mapIt.key();
			}
		}
		return VarType();
	}

	VarType Map::GetNextKey(const VarType& key)
	{
		if (omp_get_thread_num() == 0) // Main thread
		{
			if (mapIt && mapIt->hasNext())
			{
				mapIt->next();
				return mapIt->key();
			}
		}
		else
		{
			QMapIterator<VarType, Map::MapValue> mapIt(map);
			BoolType foundKey = false;
			while (mapIt.hasNext())
			{
				mapIt.next();
				if (foundKey)
					return mapIt.key();
				if (mapIt.key() == key)
					foundKey = true;
			}
		}
		return VarType();
	}

	void Map::Clear()
	{
		// Clear datastructures referenced by the map
		QMapIterator<VarType, MapValue> clearIt(map);
		while (clearIt.hasNext())
		{
			clearIt.next();
			const MapValue& mVal = map[clearIt.key()];
			if (mVal.dsType == ds_type_list)
				delete FindList(mVal.value);
			else if (mVal.dsType == ds_type_map)
				delete FindMap(mVal.value);
		}
		map.clear();
	}

	void Map::Debug() const
	{
		QMapIterator<VarType, MapValue> debIt(map);
		while (debIt.hasNext())
		{
			debIt.next();
			VarType key = debIt.key();
			const MapValue& mVal = map.value(key);
			QString line = debIt.key().ToStr() + " => " + mVal.value.ToStr();

			if (mVal.dsType == ds_type_list)
			{
				DEBUG(line + " [List]");
				Printer::indent++;
				if (List* list = FindList(mVal.value))
					list->Debug();
				Printer::indent--;
			}
			else if (mVal.dsType == ds_type_map)
			{
				DEBUG(line + " [Map]");
				Printer::indent++;
				if (Map* map = FindMap(mVal.value))
					map->Debug();
				Printer::indent--;
			}
			else
			{
				DEBUG(line + " [" + TypeName(mVal.value.GetType()) + "]");
				mVal.value.Debug();
			}
		}
	}
}