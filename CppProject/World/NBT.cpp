#include "NBT.hpp"
#include "GZIP.hpp"
#include "Generated/GmlFunc.hpp"

#include <QtEndian>

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
		ds(&data, QIODevice::ReadOnly), data(data), debug(debug)
	{
		ds.setByteOrder(QDataStream::BigEndian);

		for (auto it = filter.constBegin(); it != filter.constEnd(); ++it)
			for (const StringType& name : it.value())
				this->filter[it.key()].append(name.QStr().toUtf8());

		// Read unnamed root
		int8_t root = 0;
		ds >> root;
		if (root != TAG_COMPOUND)
			throw "Unexpected root tag " + NumStr(root);
		
		SkipString();
	}

	NbtTag* NbtStream::ReadTag(NbtType type, Context context)
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
			case TAG_LIST:			return new NbtList(*this, context);
			case TAG_COMPOUND:		return new NbtCompound(*this, context);
			case TAG_INT_ARRAY:		return new NbtIntArray(*this);
			case TAG_LONG_ARRAY:	return new NbtLongArray(*this);
		}

		throw "Unknown tag " + NumStr(type);
		return nullptr;
	}

	void NbtStream::SkipBytes(qint64 size)
	{
		qint64 pos = ds.device()->pos();
		if (ds.status() != QDataStream::Ok || size < 0 || size > data.size() - pos || !ds.device()->seek(pos + size))
			throw QString("Truncated NBT payload");
	}

	int32_t NbtStream::ReadLength(int elementSize)
	{
		int32_t size = 0;
		ds >> size;
		qint64 bytes = qint64(size) * elementSize;
		if (ds.status() != QDataStream::Ok || size < 0 || bytes > std::numeric_limits<int>::max() || bytes > ds.device()->bytesAvailable())
			throw QString("Invalid NBT array length");

		return size;
	}

	BoolType NbtStream::KeepChunkTag(NbtType type, const QByteArray& name, Context context, Context& child) const
	{
		// Keep palette and block entity subtrees intact
		child = COMPLETE;
		if (context == CHUNK)
		{
			if (type == TAG_COMPOUND && name == "Level")
			{
				child = CHUNK;
				return true;
			}

			if (type == TAG_LIST && (name == "sections" || name == "Sections"))
			{
				child = SECTION;
				return true;
			}

			return (type == TAG_INT && (name == "DataVersion" || name == "xPos" || name == "zPos")) ||
				(type == TAG_STRING && name == "Status") ||
				(type == TAG_LIST && (name == "block_entities" || name == "TileEntities")) ||
				(type == TAG_BYTE_ARRAY && (name == "Blocks" || name == "Data" || name == "Add"));
		}

		if (context == SECTION)
		{
			if (type == TAG_COMPOUND && name == "block_states")
			{
				child = BLOCK_STATES;
				return true;
			}

			return (type == TAG_BYTE && name == "Y") ||
				(type == TAG_LIST && name == "Palette") ||
				(type == TAG_LONG_ARRAY && name == "BlockStates") ||
				(type == TAG_BYTE_ARRAY && (name == "Blocks" || name == "Data" || name == "Add"));
		}

		return (type == TAG_LIST && name == "palette") || (type == TAG_LONG_ARRAY && name == "data");
	}

	BoolType NbtStream::SelectSection()
	{
		qint64 start = ds.device()->pos();
		while (true)
		{
			int8_t type = 0;
			ds >> type;
			if (ds.status() != QDataStream::Ok || type == TAG_END)
				throw QString("Missing NBT section Y");

			QByteArray name = ReadStringBytes();
			if (type == TAG_BYTE && name == "Y")
			{
				int8_t y = 0;
				ds >> y;
				if (ds.status() != QDataStream::Ok)
					throw QString("Truncated NBT section Y");

				if (y < sectionMin || y > sectionMax)
				{
					// Skip the remaining fields without constructing this section
					SkipTag(TAG_COMPOUND);
					return false;
				}

				// Y can appear anywhere in the compound
				if (!ds.device()->seek(start))
					throw QString("Could not rewind NBT section");

				return true;
			}

			SkipTag((NbtType)type);
		}
	}

	void NbtStream::SkipTag(NbtType type)
	{
		switch (type)
		{
			case TAG_BYTE:		SkipBytes(1); break;
			case TAG_SHORT:		SkipBytes(2); break;
			case TAG_INT:		SkipBytes(4); break;
			case TAG_LONG:		SkipBytes(8); break;
			case TAG_FLOAT:		SkipBytes(4); break;
			case TAG_DOUBLE:	SkipBytes(8); break;
			case TAG_BYTE_ARRAY:
			{
				int32_t size = ReadLength(1);
				SkipBytes(size);
				break;
			}

			case TAG_STRING:
				SkipString();
				break;
			
			case TAG_LIST:
			{
				int8_t listType = 0;
				ds >> listType;
				int32_t size = ReadLength(1);
				if (listType < TAG_END || listType >= TAG_AMOUNT || (size && listType == TAG_END))
					throw QString("Invalid NBT list type");
				
				if (IntType listTypeSize = nbtTypeSize.value((NbtType)listType, 0))
					SkipBytes(qint64(size) * listTypeSize);
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
					if (ds.status() != QDataStream::Ok)
						throw QString("Truncated NBT compound");
					
					if (!type)
						break;
					
					SkipString();
					SkipTag((NbtType)type);
				}
				break;
			}

			case TAG_INT_ARRAY:
			{
				int32_t size = ReadLength(4);
				SkipBytes(qint64(size) * 4);
				break;
			}

			case TAG_LONG_ARRAY:
			{
				int32_t size = ReadLength(8);
				SkipBytes(qint64(size) * 8);
				break;
			}

			default:
				throw "Unknown tag " + NumStr(type);
		}
	}

	StringType NbtStream::ReadString()
	{
		return DecodeString(ReadStringBytes());
	}

	QByteArray NbtStream::ReadStringBytes()
	{
		quint16 len = 0;
		ds >> len;
		qint64 pos = ds.device()->pos();
		SkipBytes(len);

		// Borrow bytes from the source buffer until the retained string is decoded
		return QByteArray::fromRawData(data.constData() + pos, len);
	}

	StringType NbtStream::DecodeString(const QByteArray& bytes)
	{
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
		SkipBytes(len);
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
		int32_t size = stream.ReadLength(1);

		value.Alloc(size, false);
		if (size && stream.ds.readRawData((char*)value.data, size) != size)
			throw QString("Truncated NBT byte array");

		if (stream.debug)
			DEBUG(NumStr(size) + " bytes");
	}

	NbtString::NbtString(NbtStream& stream) : NbtTag(TAG_STRING)
	{
		value = stream.ReadString();

		if (stream.debug)
			DEBUG(value);
	}

	NbtList::NbtList(NbtStream& stream, NbtStream::Context context) : NbtTag(TAG_LIST)
	{
		int8_t listType = 0;
		stream.ds >> listType;
		int32_t size = stream.ReadLength(1);
		if (listType < TAG_END || listType >= TAG_AMOUNT || (size && listType == TAG_END) ||
			(context == NbtStream::SECTION && size && listType != TAG_COMPOUND))
			throw QString("Invalid NBT list type");

		this->listType = (NbtType)listType;

		value.Alloc(size);
		int32_t count = 0;
		for (int32_t i = 0; i < size; i++)
		{
			if (context == NbtStream::SECTION && !stream.SelectSection())
				continue;

			value[count++] = stream.ReadTag((NbtType)listType, context);
		}

		if (count != size)
			value.Alloc(count, false);
	}

	NbtList::~NbtList()
	{
		for (IntType i = 0; i < value.Size(); i++)
			if (value[i])
				delete value[i];
		
		value.FreeData();
	}

	NbtCompound::NbtCompound(NbtStream& stream, NbtStream::Context context) : NbtTag(TAG_COMPOUND)
	{
		while (true)
		{
			int8_t type;
			stream.ds >> type;
			if (stream.ds.status() != QDataStream::Ok)
				throw QString("Truncated NBT compound");

			if (!type)
				break;

			BoolType previousFilter = stream.filterEnabled;
			QByteArray rawName = stream.ReadStringBytes();
			NbtStream::Context child = context;

			if (context != NbtStream::GENERIC && context != NbtStream::COMPLETE)
			{
				if (!stream.KeepChunkTag((NbtType)type, rawName, context, child))
				{
					stream.SkipTag((NbtType)type);
					continue;
				}
			}
			else if (context == NbtStream::GENERIC)
			{
				// Preview meshes do not use block entity contents
				if (stream.previewOnly && (rawName == "block_entities" || rawName == "TileEntities"))
				{
					stream.SkipTag((NbtType)type);
					continue;
				}

				if (!stream.previewOnly && (rawName == "palette" || rawName == "Palette" || rawName == "block_entities" || rawName == "TileEntities"))
					stream.filterEnabled = false;

				else if (stream.filterEnabled && !stream.filter.isEmpty() && !rawName.isEmpty())
				{
					if (!stream.filter.value((NbtType)type).contains(rawName))
					{
						stream.SkipTag((NbtType)type);
						continue;
					}
				}
			}

			// Only decode and intern names for retained fields
			StringType name = NbtStream::DecodeString(rawName);
			if (stream.debug)
			{
				DEBUG("[" + NumStr(type) + "] " + name);
				Printer::indent++;
			}

			value[name] = stream.ReadTag((NbtType)type, child);

			// Remove "minecraft:" from "Name" string values
			if (stream.stripNamespace && name == "Name" && type == TAG_STRING)
			{
				NbtString* str = (NbtString*)value[name];

				if (str->value.StartsWith("minecraft:"))
					str->value = str->value.Mid(MINECRAFT_ID_LENGTH);
			}

			if (stream.debug)
				Printer::indent--;

			stream.filterEnabled = previousFilter;
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
		int32_t size = stream.ReadLength(4);

		value.Alloc(size, false);
		if (size && stream.ds.readRawData((char*)value.data, size * 4) != size * 4)
			throw QString("Truncated NBT int array");

		for (int32_t i = 0; i < size; i++)
			value[i] = qFromBigEndian(value[i]);
		
		if (stream.debug)
			DEBUG(NumStr(size) + " ints");
	}

	NbtLongArray::NbtLongArray(NbtStream& stream) : NbtTag(TAG_LONG_ARRAY)
	{
		int32_t size = stream.ReadLength(8);

		value.Alloc(size, false);
		if (size && stream.ds.readRawData((char*)value.data, size * 8) != size * 8)
			throw QString("Truncated NBT long array");

		for (int32_t i = 0; i < size; i++)
			value[i] = qFromBigEndian(value[i]);

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
