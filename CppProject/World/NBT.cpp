#include "NBT.hpp"
#include "Generated/GmlFunc.hpp"

#include <zlib.h>

namespace CppProject
{
	QHash<NbtType, IntType> NbtStream::nbtTypeSize = {
		{ TAG_BYTE, 1 },
		{ TAG_SHORT, 2 },
		{ TAG_INT, 4 },
		{ TAG_LONG, 8 },
		{ TAG_FLOAT, 4 },
		{ TAG_DOUBLE, 8 }
	};

	NbtStream::NbtStream(QByteArray& data, QHash<NbtType, QVector<StringType>> filter, BoolType debug) :
		ds(&data, QIODevice::ReadOnly), filter(filter), debug(debug)
	{
		ds.setByteOrder(QDataStream::BigEndian);

		// Read unnamed root
		int8_t root;
		ds >> root;
		if (root != TAG_COMPOUND)
			throw "Unexpected root tag " + NumStr(root);
		ReadString();
	}

	NbtTag* NbtStream::ReadTag(NbtType type)
	{
		switch (type)
		{
			case TAG_BYTE: return new NbtByte(*this);
			case TAG_SHORT: return new NbtShort(*this);
			case TAG_INT: return new NbtInt(*this);
			case TAG_LONG: return new NbtLong(*this);
			case TAG_FLOAT: return new NbtFloat(*this);
			case TAG_DOUBLE: return new NbtDouble(*this);
			case TAG_BYTE_ARRAY: return new NbtByteArray(*this);
			case TAG_STRING: return new NbtString(*this);
			case TAG_LIST: return new NbtList(*this);
			case TAG_COMPOUND: return new NbtCompound(*this);
			case TAG_INT_ARRAY: return new NbtIntArray(*this);
			case TAG_LONG_ARRAY: return new NbtLongArray(*this);
		}

		throw "Unknown tag " + NumStr(type);
		return nullptr;
	}

	void NbtStream::SkipTag(NbtType type)
	{
		switch (type)
		{
			case TAG_BYTE: ds.skipRawData(1); break;
			case TAG_SHORT: ds.skipRawData(2); break;
			case TAG_INT: ds.skipRawData(4); break;
			case TAG_LONG: ds.skipRawData(8); break;
			case TAG_FLOAT: ds.skipRawData(4); break;
			case TAG_DOUBLE: ds.skipRawData(8); break;
			case TAG_BYTE_ARRAY:
			{
				int32_t size;
				ds >> size;
				ds.skipRawData(size);
				break;
			}
			case TAG_STRING:
				SkipString();
				break;
			case TAG_LIST:
			{
				int8_t listType;
				int32_t size;
				ds >> listType;
				ds >> size;
				if (IntType listTypeSize = nbtTypeSize.value((NbtType)listType, 0))
					ds.skipRawData(size * listTypeSize);
				else
					for (IntType i = 0; i < size; i++)
						SkipTag((NbtType)listType);
				break;
			}
			case TAG_COMPOUND:
			{
				while (true)
				{
					int8_t type;
					ds >> type;
					if (!type)
						break;
					SkipString();
					SkipTag((NbtType)type);
				}
				break;
			}
			case TAG_INT_ARRAY:
			{
				int32_t size;
				ds >> size;
				ds.skipRawData(size * 4);
				break;
			}
			case TAG_LONG_ARRAY:
			{
				int32_t size;
				ds >> size;
				ds.skipRawData(size * 8);
				break;
			}
			default:
				throw "Unknown tag " + NumStr(type);
		}
	}

	StringType NbtStream::ReadString()
	{
		int16_t len;
		ds >> len;
		if (stringSkipMc && len > MINECRAFT_ID_LENGTH)
		{
			ds.skipRawData(MINECRAFT_ID_LENGTH);
			len -= MINECRAFT_ID_LENGTH;
		}

		char* str = new char[len + 1];
		ds.readRawData(str, len);
		str[len] = '\0';
		QString qStr(str);
		delete[] str;

		return qStr;
	}

	void NbtStream::SkipString()
	{
		int16_t len;
		ds >> len;
		ds.skipRawData(len);
	}

	NbtByte::NbtByte(NbtStream& stream) : NbtTag(TAG_BYTE)
	{
		stream.ds >> value;
		if (stream.debug)
			DEBUG(NumStr(value));
	}

	NbtShort::NbtShort(NbtStream& stream) : NbtTag(TAG_SHORT)
	{
		stream.ds >> value;
		if (stream.debug)
			DEBUG(NumStr(value));
	}

	NbtInt::NbtInt(NbtStream& stream) : NbtTag(TAG_INT)
	{
		stream.ds >> value;
		if (stream.debug)
			DEBUG(NumStr(value));
	}

	NbtLong::NbtLong(NbtStream& stream) : NbtTag(TAG_LONG)
	{
		qint64 val;
		stream.ds >> val;
		value = val;
		if (stream.debug)
			DEBUG(NumStr(value));
	}

	NbtFloat::NbtFloat(NbtStream& stream) : NbtTag(TAG_FLOAT)
	{
		qint32 floatBytes;
		stream.ds >> floatBytes;
		value = CAST_BITS(float, floatBytes);
		if (stream.debug)
			DEBUG(NumStr(value));
	}

	NbtDouble::NbtDouble(NbtStream& stream) : NbtTag(TAG_DOUBLE)
	{
		qint64 dbBytes;
		stream.ds >> dbBytes;
		value = CAST_BITS(double, dbBytes);
		if (stream.debug)
			DEBUG(NumStr(value));
	}

	NbtByteArray::NbtByteArray(NbtStream& stream) : NbtTag(TAG_BYTE_ARRAY)
	{
		int32_t size;
		stream.ds >> size;
		value.Alloc(size);
		stream.ds.readRawData((char*)value.data, size);
		if (stream.debug)
			DEBUG(NumStr(size) + " bytes");
	}

	NbtString::NbtString(NbtStream& stream) : NbtTag(TAG_STRING)
	{
		value = stream.ReadString();
		if (stream.debug)
			DEBUG(value);
	}

	NbtList::NbtList(NbtStream& stream) : NbtTag(TAG_LIST)
	{
		int8_t listType;
		int32_t size;
		stream.ds >> listType;
		stream.ds >> size;
		this->listType = (NbtType)listType;
		value.Alloc(size);
		for (int32_t i = 0; i < size; i++)
			value[i] = stream.ReadTag((NbtType)listType);
	}

	NbtList::~NbtList()
	{
		for (IntType i = 0; i < value.Size(); i++)
			if (value[i])
				delete value[i];
		value.FreeData();
	}

	NbtCompound::NbtCompound(NbtStream& stream) : NbtTag(TAG_COMPOUND)
	{
		while (true)
		{
			int8_t type;
			stream.ds >> type;
			if (!type)
				break;

			BoolType resetSkipMcId = false, resetFilter = false;
			StringType name = stream.ReadString();
			if (!name.IsEmpty())
			{
				if (name == "palette" && type == TAG_LIST) // Skip minecraft: in biome ids and disable filter
					stream.stringSkipMc = true, stream.filterEnabled = false, resetSkipMcId = true, resetFilter = true;

				else if (name == "palette" || name == "Palette" || name == "block_entities" || name == "TileEntities") // Disable filter for block palette/entities
					stream.filterEnabled = false, resetFilter = true;

				else if (name == "Name") // Skip minecraft: in block ids
					stream.stringSkipMc = true, resetSkipMcId = true;

				else if (stream.filterEnabled && !stream.filter.isEmpty()) // Check name with filter
				{
					if (!stream.filter.value((NbtType)type).contains(name))
					{
						stream.SkipTag((NbtType)type);
						continue;
					}
				}
			}

			if (stream.debug)
			{
				DEBUG("[" + NumStr(type) + "] " + name);
				Printer::indent++;
			}

			value[name] = stream.ReadTag((NbtType)type);

			if (stream.debug)
				Printer::indent--;

			if (resetSkipMcId)
				stream.stringSkipMc = false;
			if (resetFilter)
				stream.filterEnabled = true;
		}
	}

	NbtCompound::~NbtCompound()
	{
		QHashIterator<StringType, NbtTag*> it(value);
		while (it.hasNext())
		{
			it.next();
			NbtTag* tag = it.value();
			delete tag;
		}
	}

	Map* NbtCompound::ToMap() const
	{
		StringHashMap* map = new StringHashMap;

		// Parse a NBT tag and return a VarType/DS type pair
		function<QPair<VarType, IntType>(NbtTag*)> toVarType;
		toVarType = [&toVarType](NbtTag* tag)
		{
			VarType val;
			IntType dsType = 0;

			switch (tag->type)
			{
				case TAG_BYTE: val = (IntType)((NbtByte*)tag)->value; break;
				case TAG_SHORT: val = (IntType)((NbtShort*)tag)->value; break;
				case TAG_INT: val = (IntType)((NbtInt*)tag)->value; break;
				case TAG_LONG: val = (IntType)((NbtLong*)tag)->value; break;
				case TAG_FLOAT: val = (RealType)((NbtFloat*)tag)->value; break;
				case TAG_DOUBLE: val = (RealType)((NbtDouble*)tag)->value; break;
				case TAG_BYTE_ARRAY:
				{
					val = ArrType();
					const Heap<int8_t>& data = ((NbtByteArray*)tag)->value;
					val.Arr().vec.Alloc(data.Size());
					for (IntType i = 0; i < data.Size(); i++)
						val.Arr().Append((IntType)data.Value(i));
					break;
				}
				case TAG_STRING: val = ((NbtString*)tag)->value; break;
				case TAG_LIST:
				{
					CppProject::List* list = new CppProject::List;
					const Heap<NbtTag*>& data = ((NbtList*)tag)->value;
					list->vec.resize(data.Size());
					for (IntType i = 0; i < data.Size(); i++)
					{
						auto var = toVarType(data.Value(i));
						List::ListValue listVal = { var.first, var.second };
						list->vec[i] = listVal;
					}

					val = list->id;
					dsType = ds_type_list;
					break;
				}
				case TAG_COMPOUND:
				{
					val = (((NbtCompound*)tag)->ToMap())->id;
					dsType = ds_type_map;
					break;
				}
				case TAG_INT_ARRAY:
				{
					val = ArrType();
					const Heap<int32_t>& data = ((NbtIntArray*)tag)->value;
					val.Arr().vec.Alloc(data.Size());
					for (IntType i = 0; i < data.Size(); i++)
						val.Arr().Append((IntType)data.Value(i));
					break;
				}
				case TAG_LONG_ARRAY:
				{
					val = ArrType();
					const Heap<int64_t>& data = ((NbtLongArray*)tag)->value;
					val.Arr().vec.Alloc(data.Size());
					for (IntType i = 0; i < data.Size(); i++)
						val.Arr().Append((IntType)data.Value(i));
					break;
				}
			}

			return QPair<VarType, IntType>(val, dsType);
		};

		QHashIterator<StringType, NbtTag*> it(value);
		while (it.hasNext())
		{
			it.next();
			auto var = toVarType(it.value());
			Map::MapValue mapVal = { var.first, var.second };
			map->hash[it.key()] = mapVal;
		}

		return map;
	}

	NbtIntArray::NbtIntArray(NbtStream& stream) : NbtTag(TAG_INT_ARRAY)
	{
		int32_t size;
		stream.ds >> size;
		value.Alloc(size);
		for (int32_t i = 0; i < size; i++)
			stream.ds >> value[i];
		if (stream.debug)
			DEBUG(NumStr(size) + " ints");
	}

	NbtLongArray::NbtLongArray(NbtStream& stream) : NbtTag(TAG_LONG_ARRAY)
	{
		int32_t size;
		stream.ds >> size;
		value.Alloc(size);
		for (int32_t i = 0; i < size; i++)
		{
			qint64 val;
			stream.ds >> val;
			value[i] = val;
		}
		if (stream.debug)
			DEBUG(NumStr(size) + " longs");
	}
}