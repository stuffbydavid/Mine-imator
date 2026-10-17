#include "NBT.hpp"
#include "GZIP.hpp"
#include "Generated/GmlFunc.hpp"

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
			case TAG_BYTE:			return new NbtByte(*this);
			case TAG_SHORT:			return new NbtShort(*this);
			case TAG_INT:			return new NbtInt(*this);
			case TAG_LONG:			return new NbtLong(*this);
			case TAG_FLOAT:			return new NbtFloat(*this);
			case TAG_DOUBLE:		return new NbtDouble(*this);
			case TAG_BYTE_ARRAY:	return new NbtByteArray(*this);
			case TAG_STRING:		return new NbtString(*this);
			case TAG_LIST:			return new NbtList(*this);
			case TAG_COMPOUND:		return new NbtCompound(*this);
			case TAG_INT_ARRAY:		return new NbtIntArray(*this);
			case TAG_LONG_ARRAY:	return new NbtLongArray(*this);
		}

		throw "Unknown tag " + NumStr(type);
		return nullptr;
	}

	void NbtStream::SkipTag(NbtType type)
	{
		switch (type)
		{
			case TAG_BYTE:		ds.skipRawData(1); break;
			case TAG_SHORT:		ds.skipRawData(2); break;
			case TAG_INT:		ds.skipRawData(4); break;
			case TAG_LONG:		ds.skipRawData(8); break;
			case TAG_FLOAT:		ds.skipRawData(4); break;
			case TAG_DOUBLE:	ds.skipRawData(8); break;
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
		quint16 len = 0;
		ds >> len;
		QByteArray bytes(len, '\0');

		if (ds.status() != QDataStream::Ok || ds.readRawData(bytes.data(), len) != len)
			throw QString("Truncated NBT string");

		if (!bytes.contains(char(0xC0)) && !bytes.contains(char(0xED)))
			return QString::fromUtf8(bytes);

		// Preserve modified UTF-8 nulls and surrogate pairs in tile entity text
		QString value;
		value.reserve(bytes.size());
		for (int i = 0; i < bytes.size();)
		{
			uint32_t code = uint8_t(bytes[i++]);
			int extra = 0;
			if (code >= 0xF0 && code < 0xF8)
			{
				code &= 0x07;
				extra = 3;
			}
			else if (code >= 0xE0 && code < 0xF0)
			{
				code &= 0x0F;
				extra = 2;
			}
			else if (code >= 0xC0 && code < 0xE0)
			{
				code &= 0x1F;
				extra = 1;
			}
			else if (code >= 0x80)
				throw QString("Invalid NBT string encoding");

			if (i + extra > bytes.size())
				throw QString("Truncated NBT string encoding");

			for (int n = 0; n < extra; n++)
			{
				uint8_t next = bytes[i++];
				if ((next & 0xC0) != 0x80)
					throw QString("Invalid NBT string encoding");

				code = (code << 6) | (next & 0x3F);
			}

			if (code > 0x10FFFF)
				throw QString("Invalid NBT string code point");

			if (code > 0xFFFF)
			{
				value.append(QChar(QChar::highSurrogate(code)));
				value.append(QChar(QChar::lowSurrogate(code)));
			}
			else
				value.append(QChar(ushort(code)));
		}
		return value;
	}

	void NbtStream::SkipString()
	{
		quint16 len = 0;
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
			if (stream.ds.status() != QDataStream::Ok)
				throw QString("Truncated NBT compound");

			if (!type)
				break;

			BoolType resetFilter = false;
			StringType name = stream.ReadString();
			if (!name.IsEmpty())
			{
				if (name == "palette" && type == TAG_LIST) // Disable filter
					stream.filterEnabled = false, resetFilter = true;

				else if (name == "palette" || name == "Palette" || name == "block_entities" || name == "TileEntities") // Disable filter for block palette/entities
					stream.filterEnabled = false, resetFilter = true;

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

			// Remove "minecraft:" from "Name" string values
			if (stream.stripNamespace && name == "Name" && type == TAG_STRING)
			{
				NbtString* str = (NbtString*)value[name];

				if (str->value.StartsWith("minecraft:"))
					str->value = str->value.Mid(MINECRAFT_ID_LENGTH);
			}

			if (stream.debug)
				Printer::indent--;

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
				case TAG_BYTE:		val = (IntType)((NbtByte*)tag)->value; break;
				case TAG_SHORT:		val = (IntType)((NbtShort*)tag)->value; break;
				case TAG_INT:		val = (IntType)((NbtInt*)tag)->value; break;
				case TAG_LONG:		val = (IntType)((NbtLong*)tag)->value; break;
				case TAG_FLOAT:		val = (RealType)((NbtFloat*)tag)->value; break;
				case TAG_DOUBLE:	val = (RealType)((NbtDouble*)tag)->value; break;
				case TAG_BYTE_ARRAY:
				{
					val = ArrType();
					const Heap<int8_t>& data = ((NbtByteArray*)tag)->value;

					val.Arr().vec.Alloc(data.Size());
					
					for (IntType i = 0; i < data.Size(); i++)
						val.Arr().Append((IntType)data.Value(i));
					
					break;
				}

				case TAG_STRING:	val = ((NbtString*)tag)->value; break;
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

	static void WriteNbtString(QDataStream& stream, const QString& value)
	{
		// Java NBT uses modified UTF-8, encoding UTF-16 surrogate pairs separately
		QByteArray bytes;
		for (QChar character : value)
		{
			ushort code = character.unicode();
			if (code > 0 && code < 0x80)
				bytes.append(char(code));
			else if (code < 0x800)
			{
				bytes.append(char(0xC0 | (code >> 6)));
				bytes.append(char(0x80 | (code & 0x3F)));
			}
			else
			{
				bytes.append(char(0xE0 | (code >> 12)));
				bytes.append(char(0x80 | ((code >> 6) & 0x3F)));
				bytes.append(char(0x80 | (code & 0x3F)));
			}

			if (bytes.size() > std::numeric_limits<quint16>::max())
				throw QString("NBT string exceeds the length limit");
		}

		stream << quint16(bytes.size());
		stream.writeRawData(bytes.constData(), bytes.size());
	}

	static void WriteNbtLength(QDataStream& stream, IntType size)
	{
		if (size < 0 || size > std::numeric_limits<qint32>::max())
			throw QString("NBT array exceeds the length limit");

		stream << qint32(size);
	}

	static void WriteNbtTag(QDataStream& stream, const NbtTag& tag)
	{
		switch (tag.type)
		{
			case TAG_BYTE:	stream << qint8(static_cast<const NbtByte&>(tag).value); break;
			case TAG_SHORT: stream << qint16(static_cast<const NbtShort&>(tag).value); break;
			case TAG_INT:	stream << qint32(static_cast<const NbtInt&>(tag).value); break;
			case TAG_LONG:	stream << qint64(static_cast<const NbtLong&>(tag).value); break;

			case TAG_FLOAT:
			{
				quint32 bits;
				memcpy(&bits, &static_cast<const NbtFloat&>(tag).value, sizeof(bits));
				stream << bits;
				break;
			}

			case TAG_DOUBLE:
			{
				quint64 bits;
				memcpy(&bits, &static_cast<const NbtDouble&>(tag).value, sizeof(bits));
				stream << bits;
				break;
			}

			case TAG_STRING:
				WriteNbtString(stream, static_cast<const NbtString&>(tag).value);
				break;

			case TAG_BYTE_ARRAY:
			{
				const auto& value = static_cast<const NbtByteArray&>(tag).value;
				WriteNbtLength(stream, value.Size());
				stream.writeRawData(reinterpret_cast<const char*>(value.Data()), int(value.Size()));
				break;
			}

			case TAG_INT_ARRAY:
			{
				const auto& value = static_cast<const NbtIntArray&>(tag).value;
				WriteNbtLength(stream, value.Size());
				for (IntType i = 0; i < value.Size(); i++)
					stream << qint32(value.Value(i));
				
				break;
			}

			case TAG_LONG_ARRAY:
			{
				const auto& value = static_cast<const NbtLongArray&>(tag).value;
				WriteNbtLength(stream, value.Size());
				for (IntType i = 0; i < value.Size(); i++)
					stream << qint64(value.Value(i));
				
				break;
			}

			case TAG_LIST:
			{
				const auto& list = static_cast<const NbtList&>(tag);
				if (list.listType < TAG_END || list.listType >= TAG_AMOUNT || (list.listType == TAG_END && list.value.Size()))
					throw QString("Invalid NBT list type");

				stream << qint8(list.listType);
				WriteNbtLength(stream, list.value.Size());

				for (IntType i = 0; i < list.value.Size(); i++)
				{
					const NbtTag* item = list.value.Value(i);
					if (!item || item->type != list.listType)
						throw QString("Mismatched NBT list element");

					WriteNbtTag(stream, *item);
				}

				break;
			}

			case TAG_COMPOUND:
			{
				const auto& value = static_cast<const NbtCompound&>(tag).value;
				for (auto it = value.constBegin(); it != value.constEnd(); ++it)
				{
					const NbtTag* child = it.value();
					if (!child || child->type <= TAG_END || child->type >= TAG_AMOUNT)
						throw QString("Invalid NBT compound element");

					stream << qint8(child->type);
					
					WriteNbtString(stream, it.key());
					WriteNbtTag(stream, *child);
				}
				
				stream << qint8(TAG_END);
				
				break;
			}

			default:
				throw QString("Unknown NBT tag type");
		}
	}

	void NbtCompound::WriteFile(const QString& filename, const QString& rootName) const
	{
		Gzip::WriteCompressed(Serialize(rootName), filename);
	}

	QByteArray NbtCompound::Serialize(const QString& rootName) const
	{
		QByteArray data;
		QDataStream stream(&data, QIODevice::WriteOnly);
		stream.setByteOrder(QDataStream::BigEndian);
		stream << qint8(TAG_COMPOUND);

		WriteNbtString(stream, rootName);
		WriteNbtTag(stream, *this);

		if (stream.status() != QDataStream::Ok)
			throw QString("Could not serialize NBT data");

		return data;
	}
}
