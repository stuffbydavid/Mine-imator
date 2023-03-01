#pragma once

#include "Common.hpp"
#include "Heap.hpp"

#include "Asset/DataStructure.hpp"

#include <QVariant>

#define MINECRAFT_ID_LENGTH 10

namespace CppProject
{
	struct NbtTag;

	enum NbtType
	{
		TAG_END = 0,
		TAG_BYTE = 1,
		TAG_SHORT = 2,
		TAG_INT = 3,
		TAG_LONG = 4,
		TAG_FLOAT = 5,
		TAG_DOUBLE = 6,
		TAG_BYTE_ARRAY = 7,
		TAG_STRING = 8,
		TAG_LIST = 9,
		TAG_COMPOUND = 10,
		TAG_INT_ARRAY = 11,
		TAG_LONG_ARRAY = 12,
		TAG_AMOUNT
	};

	struct NbtStream
	{
		NbtStream(QByteArray& data, QHash<NbtType, QVector<StringType>> filter = {}, BoolType debug = false);

		NbtTag* ReadTag(NbtType type);
		void SkipTag(NbtType type);

		StringType ReadString();
		void SkipString();

		QDataStream ds;
		QHash<NbtType, QVector<StringType>> filter;
		BoolType stringSkipMc = false, filterEnabled = true, debug = false;

		static QHash<NbtType, IntType> nbtTypeSize;
	};

	struct NbtTag
	{
		NbtTag(NbtType type) : type(type) {}
		virtual ~NbtTag() {}
		NbtType type;
	};

	struct NbtByte : NbtTag
	{
		NbtByte(NbtStream& stream);
		int8_t value;
	};

	struct NbtShort : NbtTag
	{
		NbtShort(NbtStream& stream);
		int16_t value;
	};

	struct NbtInt : NbtTag
	{
		NbtInt(NbtStream& stream);
		int32_t value;
	};

	struct NbtLong : NbtTag
	{
		NbtLong(NbtStream& stream);
		int64_t value;
	};

	struct NbtFloat : NbtTag
	{
		NbtFloat(NbtStream& stream);
		float value;
	};

	struct NbtDouble : NbtTag
	{
		NbtDouble(NbtStream& stream);
		double value;
	};

	struct NbtByteArray : NbtTag
	{
		NbtByteArray(NbtStream& stream);
		Heap<int8_t> value;
	};

	struct NbtString : NbtTag
	{
		NbtString(NbtStream& stream);
		StringType value;
	};

	struct NbtList : NbtTag
	{
		NbtList(NbtStream& stream);
		~NbtList();
		NbtType listType;
		Heap<NbtTag*> value;
	};

	struct NbtIntArray : NbtTag
	{
		NbtIntArray(NbtStream& stream);
		Heap<int32_t> value;
	};

	struct NbtLongArray : NbtTag
	{
		NbtLongArray(NbtStream& stream);
		Heap<int64_t> value;
	};

	struct NbtCompound : NbtTag
	{
		NbtCompound(NbtStream& stream);
		~NbtCompound();

		// Compound value access
		BoolType HasKey(const StringType& key) const { return value.contains(key); }
		NbtType GetType(const StringType& key) const { return value.contains(key) ? value.value(key)->type : TAG_END; }
		int8_t& Byte(const StringType& key) { return Get<NbtByte, TAG_BYTE, int8_t>(key); }
		int16_t& Short(const StringType& key) { return Get<NbtShort, TAG_SHORT, int16_t>(key); }
		int32_t& Int(const StringType& key) { return Get<NbtInt, TAG_INT, int32_t>(key); }
		int64_t& Long(const StringType& key) { return Get<NbtLong, TAG_LONG, int64_t>(key); }
		float& Float(const StringType& key) { return Get<NbtFloat, TAG_FLOAT, float>(key); }
		double& Double(const StringType& key) { return Get<NbtDouble, TAG_DOUBLE, double>(key); }
		Heap<int8_t>& ByteArray(const StringType& key) { return Get<NbtByteArray, TAG_BYTE_ARRAY, Heap<int8_t>>(key); }
		StringType& String(const StringType& key) { return Get<NbtString, TAG_STRING, StringType>(key); }
		Heap<int32_t>& IntArray(const StringType& key) { return Get<NbtIntArray, TAG_INT_ARRAY, Heap<int32_t>>(key); }
		Heap<int64_t>& LongArray(const StringType& key) { return Get<NbtLongArray, TAG_LONG_ARRAY, Heap<int64_t>>(key); }

		// Compound list access
		template<int ListTagType, typename ListStruct> QVector<ListStruct*> List(const StringType& key)
		{
			NbtTag* tag = value.value(key, nullptr);
			if (!tag)
				throw "Key " + (QString)key + " not found in compound";
			if (tag->type != TAG_LIST)
				throw "Unexpected type of key " + (QString)key + " compound: " + NumStr(tag->type);

			NbtList* tagList = (NbtList*)tag;
			if (!tagList->value.Size())
				return QVector<ListStruct*>();

			if (tagList->listType != ListTagType)
				throw "Unexpected list type of key " + (QString)key + " compound: " + NumStr(tagList->listType);

			QVector<ListStruct*> list;
			for (IntType i = 0; i < tagList->value.Size(); i++)
				list.append((ListStruct*)tagList->value[i]);
			return list;
		}

		// Nested compound access
		NbtCompound* Compound(const StringType& key)
		{
			NbtTag* tag = value.value(key, nullptr);
			if (!tag)
				throw "Key " + (QString)key + " not found in compound";
			if (tag->type != TAG_COMPOUND)
				throw "Unexpected type of key " + (QString)key + " compound: " + NumStr(tag->type);
			return (NbtCompound*)tag;
		}

		// Convert the compound data to a new map/list structure.
		Map* ToMap() const;

		QHash<StringType, NbtTag*> value;

	private:
		template<typename St, int Et, typename Vt> Vt& Get(const StringType& key)
		{
			NbtTag* tag = value.value(key, nullptr);
			if (!tag)
				throw "Key " + (QString)key + " not found in compound";
			if (tag->type != Et)
				throw "Unexpected type of key " + (QString)key + " compound: " + NumStr(tag->type);
			return ((St*)tag)->value;
		}
	};
}