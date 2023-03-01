#include "DataStructure.hpp"

#include "Generated/GmlFunc.hpp"

#define KEY_EXIST_CHECK !RELEASE_MODE

namespace CppProject
{
	template struct HashMap<IntType>;
	template struct HashMap<StringType>;

	template <typename T> HashMap<T>::~HashMap()
	{
		deleteAndReset(hashIt);
	}

	template <typename T> void HashMap<T>::Copy(Map* to) const
	{
		if (to->GetType() == MAP)
		{
			to->map.clear();
			QHashIterator<T, MapValue> copyIt(hash);
			while (copyIt.hasNext())
			{
				copyIt.next();
				to->map[copyIt.key()] = copyIt.value();
			}
		}
		else if (HashMap<T>* toHash = dynamic_cast<HashMap<T>*>(to))
			toHash->hash = hash;
	}

	template <typename T> VarType HashMap<T>::GetFirstKey()
	{
		if (omp_get_thread_num() == 0) // Main thread
		{
			deleteAndReset(hashIt);
			hashIt = new QHashIterator<T, Map::MapValue>(hash);
			if (hashIt->hasNext())
			{
				hashIt->next();
				return VarType(hashIt->key());
			}
		}
		else
		{
			QHashIterator<T, Map::MapValue> hashIt(hash);
			if (hashIt.hasNext())
			{
				hashIt.next();
				return VarType(hashIt.key());
			}
		}
		return VarType();
	}

	template <typename T> VarType HashMap<T>::GetNextKey(const VarType& key)
	{
		if (omp_get_thread_num() == 0) // Main thread
		{
			if (hashIt && hashIt->hasNext())
			{
				hashIt->next();
				return VarType(hashIt->key());
			}
		}
		else
		{
			QHashIterator<T, Map::MapValue> hashIt(hash);
			BoolType foundKey = false;
			while (hashIt.hasNext())
			{
				hashIt.next();
				if (foundKey)
					return VarType(hashIt.key());
				if (hashIt.key() == (T)key)
					foundKey = true;
			}
		}
		return VarType();
	}

	template <typename T> void HashMap<T>::Clear()
	{
		// Clear datastructures referenced by the hash table
		QHashIterator<T, MapValue> clearIt(hash);
		while (clearIt.hasNext())
		{
			clearIt.next();
			const MapValue& hVal = hash[clearIt.key()];
			if (hVal.dsType == ds_type_list)
				delete FindList(hVal.value);
			else if (hVal.dsType == ds_type_map)
				delete FindMap(hVal.value);
		}
		hash.clear();
	}

	template <typename T> void HashMap<T>::Debug() const
	{
		QHashIterator<T, MapValue> debIt(hash);
		while (debIt.hasNext())
		{
			debIt.next();
			T key = debIt.key();
			const MapValue& hVal = hash.value(key);
			QString line = VarType(debIt.key()).ToStr() + " => " + hVal.value.ToStr();

			if (hVal.dsType == ds_type_list)
			{
				DEBUG(line + " [List]");
				Printer::indent++;
				if (List* list = FindList(hVal.value))
					list->Debug();
				Printer::indent--;
			}
			else if (hVal.dsType == ds_type_map)
			{
				DEBUG(line + " [Map]");
				Printer::indent++;
				if (Map* map = FindMap(hVal.value))
					map->Debug();
				Printer::indent--;
			}
			else
			{
				DEBUG(line + " [" + TypeName(hVal.value.GetType()) + "]");
				hVal.value.Debug();
			}
		}
	}
}