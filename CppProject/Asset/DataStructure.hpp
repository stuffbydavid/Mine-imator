#pragma once
#include "Asset.hpp"
#include "Heap.hpp"
#include "Type/VarType.hpp"
#include "Type/ArrType.hpp"
#include "Type/VecType.hpp"

namespace CppProject
{
	// Map data structure
	struct Map : Asset
	{
		Map(IntType subAssetId = 0) : Asset(ID_Map, subAssetId) {};
		virtual ~Map();

		struct MapValue
		{
			VarType value;
			IntType dsType = 0;
		};

		virtual VarType& operator[](const VarType& key) { return map[key].value; } // map[key] = ..

		// Returns a value at the given key.
		virtual VarType Value(const VarType& key) const;
		virtual VarType Value(IntType key) const { return Value(VarType(key)); };
		virtual VarType Value(const char* key) const { return Value(VarType(key)); };

		// Sets the value and datastructure type of a key.
		virtual void Set(const VarType& key, MapValue value) { map[key] = value; }

		// Removes the value at a key.
		virtual void Remove(const VarType& key) { map.remove(key); }

		// Returns whether the map contains a key.
		virtual BoolType Contains(const VarType& key) const { return map.contains(key); }

		// Copy the values in the map to another.
		virtual void Copy(Map* to) const;

		// Finds the first key.
		virtual VarType GetFirstKey();

		// Finds the next key.
		virtual VarType GetNextKey(const VarType& key);

		// Returns the size of the map.
		virtual IntType GetSize() { return map.size(); }

		// Clear map keys and values and recursively destroys data structures.
		virtual void Clear();

		// Debug map key/value mappings.
		virtual void Debug() const;

		QMap<VarType, MapValue> map;
		QMapIterator<VarType, MapValue>* mapIt = nullptr;

		enum Type
		{
			MAP,
			HASH_INT,
			HASH_STRING,
		};
		virtual Type GetType() const { return MAP; }
	};

	// Map data structure with a hash table for faster lookup
	template <typename T> struct HashMap : Map
	{
		using Map::Map;
		~HashMap();
		VarType& operator[](const VarType& key) override { return hash[(T)key].value; }
		VarType Value(const VarType& key) const override { return hash.value((T)key).value; }
		void Set(const VarType& key, MapValue value) override { hash[(T)key] = value; }
		void Remove(const VarType& key) override { hash.remove((T)key); }
		BoolType Contains(const VarType& key) const override { return hash.contains(key); }
		void Copy(Map* to) const override;
		VarType GetFirstKey() override;
		VarType GetNextKey(const VarType& key) override;
		IntType GetSize() override { return hash.size(); }
		void Clear() override;
		void Debug() const override;

		QHash<T, MapValue> hash;
		QHashIterator<T, MapValue>* hashIt = nullptr;
	};

	struct IntHashMap : HashMap<IntType>
	{
		IntHashMap() : HashMap(ID_IntHashMap) {}
		VarType Value(IntType key) const override { return hash.value(key).value; }
		Type GetType() const override { return HASH_INT; }
	};
	struct StringHashMap : HashMap<StringType>
	{
		StringHashMap() : HashMap(ID_StringHashMap) {}
		VarType Value(const char* key) const override { return hash.value(key).value; }
		Type GetType() const override { return HASH_STRING; }
	};

	// List data structure
	// Each element is a struct with { value, dsType }
	struct List : Asset
	{
		List() : Asset(ID_List) {};
		~List();

		VarType& operator[](IntType); // list[index] = value

		// Returns the value at an index.
		const VarType& Value(IntType index) const;

		// Clear the list and recursively destroys data structures
		void Clear();

		// Debug list contents
		void Debug() const;

		struct ListValue
		{
			VarType value;
			IntType dsType = 0;
		};
		QVector<ListValue> vec;
	};

	// Stack data structure
	struct Stack : Asset
	{
		Stack() : Asset(ID_Stack) {};

		QStack<VarType> stack;
	};

	// Priority queue data structure
	// Each value is a struct with { value, priority }
	struct Priority : Asset
	{
		Priority() : Asset(ID_Priority) {};

		IntType GetMaxPrioIndex() const;

		struct PriorityValue
		{
			VarType value;
			IntType prio = 0;
		};
		QVector<PriorityValue> vec;
	};
}