#include "World.hpp"
#include "GZIP.hpp"

#include "Asset/DataStructure.hpp"

namespace CppProject
{
	SchematicExport::SchematicExport(const WorldBox& selection, IntType dataVersion, BoolType skipIncompatible, BoolType applyFilter) :
		box(selection),
		dataVersion(dataVersion),
		legacy(dataVersion < Chunk::JAVA_1_13),
		skipIncompatible(skipIncompatible),
		applyFilter(applyFilter)
	{
		if (!box.active)
			throw QString("No world selection to export");

		box.Adjust();

		const Map& entityMap = DsMap(ObjType(obj_minecraft_assets, global::mc_assets)->entity_model_map);
		for (auto it = entityMap.map.cbegin(); it != entityMap.map.cend(); ++it)
			supportedEntityIds.insert(it.key());

		WorldVec size = box.end - box.start;
		IntType maxDimension = std::numeric_limits<uint16_t>::max();
		if (legacy)
			maxDimension = std::numeric_limits<int16_t>::max();

		if (size.x <= 0 || size.y <= 0 || size.z <= 0 ||
			size.x > maxDimension || size.y > maxDimension || size.z > maxDimension)
			throw QString("Selection dimensions exceed the schematic format limits");

		IntType volume = size.x * size.y * size.z;
		if (volume > std::numeric_limits<int32_t>::max())
			throw QString("Selection volume exceeds the schematic format limits");

		schematic = &root;
		if (!legacy)
		{
			schematic = new NbtCompound;
			root.value["Schematic"] = schematic;
			schematic->value["Version"] = new NbtInt(3);
		}

		schematic->value["Width"] = new NbtShort(int16_t(size.x));
		schematic->value["Height"] = new NbtShort(int16_t(size.y));
		schematic->value["Length"] = new NbtShort(int16_t(size.z));

		// Missing and incompatible chunks remain air
		if (legacy)
		{
			schematic->value["Materials"] = new NbtString("Alpha");
			schematic->value["Entities"] = new NbtList(TAG_COMPOUND);
			schematic->value["TileEntities"] = new NbtList(TAG_COMPOUND);

			NbtByteArray* blocks = new NbtByteArray;
			NbtByteArray* data = new NbtByteArray;
			schematic->value["Blocks"] = blocks;
			schematic->value["Data"] = data;

			blocks->value.Alloc(volume);
			data->value.Alloc(volume);
		}
		else
		{
			NbtIntArray* offset = new NbtIntArray;
			schematic->value["Offset"] = offset;
			offset->value.Alloc(3);
			schematic->value["Entities"] = new NbtList(TAG_COMPOUND);

			NbtCompound* blocks = new NbtCompound;
			palette = new NbtCompound;
			entities = new NbtList(TAG_COMPOUND);
			schematic->value["Blocks"] = blocks;
			blocks->value["Palette"] = palette;
			blocks->value["BlockEntities"] = entities;
			palette->value["minecraft:air"] = new NbtInt(0);

			indices.Alloc(volume);
		}
	}

	void SchematicExport::AddChunk(Chunk& chunk)
	{
		BoolType legacyChunk = (chunk.format < Chunk::JAVA_1_13);
		if (skipIncompatible && legacy != legacyChunk)
		{
			skippedChunks++;
			return;
		}

		if (!legacy)
		{
			chunk.ExportSchematic(box, *palette, indices, *entities, applyFilter);
			dataVersion = std::max(dataVersion, chunk.dataVersion);
		}
		else
			chunk.ExportLegacySchematic(box, *schematic, applyFilter);

		AddEntities(*chunk.exportData);
	}

	void SchematicExport::AddEntities(NbtCompound& chunk)
	{
		NbtCompound* source = &chunk;
		if (chunk.HasKey("Level"))
			source = chunk.Compound("Level");

		StringType entitiesName = source->HasKey("Entities") ? "Entities" : "entities";
		if (!source->HasKey(entitiesName))
			return;

		NbtList* outputList = static_cast<NbtList*>(schematic->value.value("Entities"));

		for (NbtCompound* entity : source->List<TAG_COMPOUND, NbtCompound>(entitiesName))
		{
			if (entity->GetType("id") != TAG_STRING || entity->GetType("Pos") != TAG_LIST)
				continue;

			StringType id = entity->String("id");
			if (!supportedEntityIds.contains(id.ToLower().Replaced("minecraft:", "")))
				continue;

			NbtList* sourcePos = static_cast<NbtList*>(entity->value.value("Pos"));
			if (sourcePos->listType != TAG_DOUBLE)
				continue;

			QVector<NbtDouble*> pos = entity->List<TAG_DOUBLE, NbtDouble>("Pos");
			if (pos.size() != 3)
				continue;

			WorldVec blockPos(std::floor(pos[0]->value), std::floor(pos[1]->value), std::floor(pos[2]->value));
			if (!box.Contains(blockPos))
				continue;

			NbtCompound* output = new NbtCompound;
			outputList->value.Alloc(outputList->value.Size() + 1);
			outputList->value[outputList->value.Size() - 1] = output;

			NbtList* localPos = new NbtList(TAG_DOUBLE);
			localPos->value.Alloc(3);
			localPos->value[0] = new NbtDouble(pos[0]->value - box.start.x);
			localPos->value[1] = new NbtDouble(pos[1]->value - box.start.y);
			localPos->value[2] = new NbtDouble(pos[2]->value - box.start.z);

			output->value.swap(entity->value);
			delete output->value.take("Pos");

			if (output->GetType("block_pos") == TAG_INT_ARRAY)
			{
				Heap<int32_t>& anchor = output->IntArray("block_pos");
				if (anchor.Size() == 3)
				{
					anchor[0] -= int32_t(box.start.x);
					anchor[1] -= int32_t(box.start.y);
					anchor[2] -= int32_t(box.start.z);
				}
			}

			if (legacy)
			{
				output->value["Pos"] = localPos;
				for (const char* axis : { "TileX", "TileY", "TileZ" })
				{
					if (output->GetType(axis) != TAG_INT)
						continue;

					IntType start = (axis[4] == 'X') ? box.start.x : ((axis[4] == 'Y') ? box.start.y : box.start.z);
					output->Int(axis) -= int32_t(start);
				}
			}
			else
			{
				delete output->value.take("id");

				NbtCompound* payload = new NbtCompound;
				payload->value.swap(output->value);
				output->value["Id"] = new NbtString(id);
				output->value["Pos"] = localPos;
				output->value["Data"] = payload;
			}
		}
	}

	void SchematicExport::AddEntityRegion(const QString& filename, const WorldVec& regionPos, const BoolType* includedChunks)
	{
		QFile file(filename);
		if (!file.exists())
			return;

		if (!file.open(QFile::ReadOnly))
		{
			WARNING("Could not open entity region " + filename);
			return;
		}

		QByteArray region = file.readAll();
		if (region.size() < 8192)
			return;

		const char* bytes = region.constData();
		for (IntType i = 0; i < 1024; i++)
		{
			if (!includedChunks[i])
				continue;

			WorldVec chunkPos = regionPos + WorldVec((i & 31) * 16, box.start.y, (i >> 5) * 16);
			if (!box.Intersects({ chunkPos, chunkPos + WorldVec(16, box.end.y - box.start.y, 16) }))
				continue;

			IntType offset =
				(uint8_t(bytes[i * 4]) << 16) |
				(uint8_t(bytes[i * 4 + 1]) << 8) |
				uint8_t(bytes[i * 4 + 2]);
			
			offset *= 4096;

			if (offset == 0 || offset > region.size() - 5)
				continue;

			IntType length =
				(uint32_t(uint8_t(bytes[offset])) << 24) |
				(uint32_t(uint8_t(bytes[offset + 1])) << 16) |
				(uint32_t(uint8_t(bytes[offset + 2])) << 8) |
				uint8_t(bytes[offset + 3]);

			if (length <= 1 || length > region.size() - offset - 4)
				continue;

			QByteArray data;
			if (!Gzip::Decompress(bytes + offset + 5, length - 1, data))
				continue;

			try
			{
				NbtStream stream(data);
				NbtCompound chunk(stream);
				AddEntities(chunk);
			}
			catch (const QString& error)
			{
				WARNING("Could not read entities in " + filename + ": " + error);
			}
		}
	}

	QByteArray SchematicExport::Serialize()
	{
		if (!error.isEmpty())
			throw error;

		if (skippedChunks)
			WARNING("Schematic snapshot omitted " + NumStr(skippedChunks) + " incompatible chunks");

		if (legacy)
			return root.Serialize("Schematic");

		delete schematic->value.take("DataVersion");
		schematic->value["DataVersion"] = new NbtInt(int32_t(dataVersion));

		// Size the varint payload before writing directly into the NBT array
		IntType dataSize = indices.Size();
		for (IntType i = 0; i < indices.Size(); i++)
		{
			for (uint32_t index = indices[i]; index >= 0x80; index >>= 7)
				dataSize++;
		}

		if (dataSize > std::numeric_limits<int32_t>::max())
			throw QString("Schematic block data exceeds the NBT array size limit");

		NbtCompound* blocks = schematic->Compound("Blocks");
		delete blocks->value.take("Data");
		NbtByteArray* blockData = new NbtByteArray;
		blocks->value["Data"] = blockData;
		blockData->value.Alloc(dataSize, false);

		// X varies fastest, followed by Z, then Y
		IntType offset = 0;
		for (IntType i = 0; i < indices.Size(); i++)
		{
			uint32_t index = indices[i];
			while (index >= 0x80)
			{
				blockData->value[offset++] = int8_t((index & 0x7F) | 0x80);
				index >>= 7;
			}
			blockData->value[offset++] = int8_t(index);
		}

		return root.Serialize();
	}

	QString SchematicExport::Extension() const
	{
		if (legacy)
			return ".schematic";

		return ".schem";
	}

	void SchematicExport::SaveResource(obj_resource* resource)
	{
		try
		{
			QByteArray data = Serialize();
			QString folder = global::_app->project_folder.Str();
			QString filename = StringType(res_get_world_filename(ScopeAny(global::_app->id), resource->world_name, Extension(), resource->id)).QStr();
			resource->filename = filename;

			Gzip::WriteAsync(std::move(data), QDir(folder).filePath(filename), "schematic");
		}
		catch (const QString& error)
		{
			WARNING("Could not save schematic snapshot: " + error);

			message_set_caption(text_get({ StringType("error/export_schematic_caption") }));
			show_message(StringType("Could not save schematic:\n" + error));
		}
	}

	void Chunk::ExportSchematic(const WorldBox& box, NbtCompound& palette, Heap<uint32_t>& indices, NbtList& entities, BoolType applyFilter)
	{
		if (!exportData)
			return;

		if (format < JAVA_1_13)
			throw text_get({ StringType("error/export_schematic_old_chunks") }).Str().QStr();

		WorldVec size = box.end - box.start;
		WorldVec chunkPos = region->pos + WorldVec(x * SECTION_SIZE, 0, z * SECTION_SIZE);
		BoolType filterEnabled = (global::_app->setting_world_filter_enabled && applyFilter);
		e_block_filter filterMode = (e_block_filter)global::_app->setting_world_filter_mode.ToInt();
		StringType sectionsName = "Sections";

		if (format >= JAVA_1_18)
			sectionsName = "sections";

		if (exportData->HasKey(sectionsName))
		{
			Heap<uint16_t> localIndices;
			QVector<uint32_t> remap;

			for (NbtCompound* section : exportData->List<TAG_COMPOUND, NbtCompound>(sectionsName))
			{
				WorldVec pos = chunkPos + WorldVec(0, section->Byte("Y") * SECTION_SIZE, 0);
				if (!box.Intersects({ pos, pos + WorldVec(SECTION_SIZE, SECTION_SIZE, SECTION_SIZE) }))
					continue;

				NbtCompound* blocks = section;
				StringType paletteName = "Palette", dataName = "BlockStates";
				if (format >= JAVA_1_18)
				{
					if (!section->HasKey("block_states"))
						continue;

					blocks = section->Compound("block_states");
					paletteName = "palette";
					dataName = "data";
				}

				if (!blocks->HasKey(paletteName))
					continue;

				// Keep original identifiers and all properties, including unknown blocks
				if (blocks->GetType(paletteName) != TAG_LIST)
					throw QString("Invalid chunk block palette");

				NbtList* sourcePalette = static_cast<NbtList*>(blocks->value.value(paletteName));
				if (!sourcePalette->value.Size() || sourcePalette->value.Size() > SECTION_SIZE3)
					throw QString("Invalid chunk block palette size");

				remap.clear();
				remap.reserve((int)sourcePalette->value.Size());

				for (IntType i = 0; i < sourcePalette->value.Size(); i++)
				{
					NbtTag* entry = sourcePalette->value[i];
					QString state;
					if (entry->type == TAG_STRING)
						state = static_cast<NbtString*>(entry)->value;

					else if (entry->type == TAG_COMPOUND)
					{
						NbtCompound* compound = static_cast<NbtCompound*>(entry);
						StringType idName = "Name", propertiesName = "Properties";
						if (format >= JAVA_26_3)
						{
							idName = "id";
							propertiesName = "properties";
							if (!compound->HasKey(idName))
								idName = "";
						}
						state = compound->String(idName);

						if (compound->HasKey(propertiesName))
						{
							NbtCompound* properties = compound->Compound(propertiesName);
							QStringList values;
							for (auto it = properties->value.constBegin(); it != properties->value.constEnd(); ++it)
								values.append(QString(it.key()) + "=" + QString(properties->String(it.key())));

							values.sort();
							if (!values.isEmpty())
								state += "[" + values.join(",") + "]";
						}
					}
					else
						throw QString("Invalid chunk block palette entry");

					if (!state.contains(':'))
						state.prepend("minecraft:");

					if (filterEnabled)
					{
						StringType id = state.section('[', 0, 0);
						if (id.StartsWith("minecraft:"))
							id = id.Mid(MINECRAFT_ID_LENGTH);

						// Reuse the importer filter, retaining unknown blocks in remove mode
						if (!Builder::filteredMcBlockIdObjMap.contains(id) &&
							(filterMode == e_block_filter_KEEP || Builder::mcBlockIdObjMap.contains(id)))
							state = "minecraft:air";

						else if (World::waterRemoved)
						{
							int start = state.indexOf('[');
							if (start >= 0)
							{
								QStringList properties = state.mid(start + 1, state.size() - start - 2).split(',');
								int waterlogged = properties.indexOf("waterlogged=true");
								if (waterlogged >= 0)
								{
									properties[waterlogged] = "waterlogged=false";
									state = state.left(start + 1) + properties.join(",") + "]";
								}
							}
						}
					}

					if (!palette.HasKey(state))
						palette.value[state] = new NbtInt(palette.value.size());

					remap.append(palette.Int(state));
				}

				// Single-entry palettes without packed data use index zero without scratch storage
				BoolType hasIndices = blocks->HasKey(dataName) && blocks->LongArray(dataName).Size();
				if (hasIndices)
				{
					const Heap<int64_t>& data = blocks->LongArray(dataName);
					IntType bits = std::max(IntType(4), IntType(std::ceil(std::log2(remap.size()))));
					IntType longs = (SECTION_SIZE3 * bits + 63) / 64;
					if (format >= JAVA_1_16)
						longs = (SECTION_SIZE3 + 64 / bits - 1) / (64 / bits);

					if (data.Size() != longs)
						throw QString("Invalid chunk block data length");

					if (!localIndices.Size())
						localIndices.Alloc(SECTION_SIZE3, false);

					Section::ParsePaletteIndices(data, localIndices, remap.size(), format, 4);
				}
				else if (remap.size() != 1)
					throw QString("Missing chunk block data");

				// Copy only blocks inside the selection, using Minecraft's Y-up ordering
				for (IntType y = std::max(pos.y, box.start.y); y < std::min(pos.y + SECTION_SIZE, box.end.y); y++)
				for (IntType z = std::max(pos.z, box.start.z); z < std::min(pos.z + SECTION_SIZE, box.end.z); z++)
				for (IntType x = std::max(pos.x, box.start.x); x < std::min(pos.x + SECTION_SIZE, box.end.x); x++)
				{
					IntType local = (y - pos.y) * SECTION_SIZE2 + (z - pos.z) * SECTION_SIZE + x - pos.x;
					uint16_t index = 0;
					if (hasIndices)
						index = localIndices[local];

					if (index >= remap.size())
						throw QString("Chunk block references a missing palette entry");

					IntType target = ((y - box.start.y) * size.z + z - box.start.z) * size.x + x - box.start.x;
					indices[target] = remap[index];
				}
			}
		}

		StringType entitiesName = "block_entities";
		if (exportData->HasKey("TileEntities"))
			entitiesName = "TileEntities";

		if (!exportData->HasKey(entitiesName))
			return;

		// Copy Tile entities, offset by box selection start
		for (NbtCompound* entity : exportData->List<TAG_COMPOUND, NbtCompound>(entitiesName))
		{
			WorldVec pos;
			if (entity->HasKey("x"))
				pos = { entity->Int("x"), entity->Int("y"), entity->Int("z") };
			else
			{
				StringType posName = "Pos";
				if (entity->HasKey("pos"))
					posName = "pos";

				if (entity->GetType(posName) == TAG_INT_ARRAY)
				{
					const auto& values = entity->IntArray(posName);
					if (values.Size() != 3)
						throw QString("Invalid block entity position");

					pos = { values.Value(0), values.Value(1), values.Value(2) };
				}
				else
				{
					auto values = entity->List<TAG_INT, NbtInt>(posName);
					if (values.size() != 3)
						throw QString("Invalid block entity position");

					pos = { values[0]->value, values[1]->value, values[2]->value };
				}
			}

			if (!box.Contains(pos))
				continue;

			// Filter by the block at this position, not the block entity's type
			IntType target = ((pos.y - box.start.y) * size.z + pos.z - box.start.z) * size.x + pos.x - box.start.x;
			if (filterEnabled && indices[target] == 0)
				continue;

			StringType idName = "id";
			if (!entity->HasKey(idName))
				idName = "Id";

			StringType id = entity->String(idName);
			NbtCompound* output = new NbtCompound;
			entities.value.Alloc(entities.value.Size() + 1);
			entities.value[entities.value.Size() - 1] = output;
			output->value["Id"] = new NbtString(id);

			NbtIntArray* position = new NbtIntArray;
			output->value["Pos"] = position;
			position->value.Alloc(3);
			position->value[0] = pos.x - box.start.x;
			position->value[1] = pos.y - box.start.y;
			position->value[2] = pos.z - box.start.z;

			// Transfer the complete payload without copying or losing NBT tag types
			NbtCompound* payload = new NbtCompound;
			output->value["Data"] = payload;
			payload->value.swap(entity->value);
			for (const char* name : { "id", "Id", "x", "y", "z", "Pos", "pos" })
				delete payload->value.take(name);
		}
	}

	void Chunk::ExportLegacySchematic(const WorldBox& box, NbtCompound& schematic, BoolType applyFilter)
	{
		if (!exportData)
			return;

		if (format >= JAVA_1_13)
			throw text_get({ StringType("error/export_schematic_new_chunks") }).Str().QStr();

		WorldVec size = box.end - box.start;
		WorldVec chunkPos = region->pos + WorldVec(x * SECTION_SIZE, 0, z * SECTION_SIZE);
		Heap<int8_t>& blocks = schematic.ByteArray("Blocks");
		Heap<int8_t>& data = schematic.ByteArray("Data");
		BoolType filterEnabled = (global::_app->setting_world_filter_enabled && applyFilter);
		e_block_filter filterMode = (e_block_filter)global::_app->setting_world_filter_mode.ToInt();

		// Both legacy layouts use packed metadata, but pre-Anvil chunks have Y varying fastest
		auto copyBlocks = [&](NbtCompound* source, const WorldVec& pos, IntType height)
			{
				if (!box.Intersects({ pos, pos + WorldVec(SECTION_SIZE, height, SECTION_SIZE) }))
					return;

				const Heap<int8_t>& sourceBlocks = source->ByteArray("Blocks");
				const Heap<int8_t>& sourceData = source->ByteArray("Data");
				const Heap<int8_t>* sourceAdd = nullptr;
				if (source->HasKey("Add"))
					sourceAdd = &source->ByteArray("Add");

				IntType count = SECTION_SIZE2 * height;
				if (sourceBlocks.Size() != count || sourceData.Size() != count / 2 ||
					(sourceAdd && sourceAdd->Size() != count / 2))
					throw QString("Invalid legacy chunk block data length");

				for (IntType y = std::max(pos.y, box.start.y); y < std::min(pos.y + height, box.end.y); y++)
				for (IntType z = std::max(pos.z, box.start.z); z < std::min(pos.z + SECTION_SIZE, box.end.z); z++)
				for (IntType x = std::max(pos.x, box.start.x); x < std::min(pos.x + SECTION_SIZE, box.end.x); x++)
				{
					IntType local = (y - pos.y) * SECTION_SIZE2 + (z - pos.z) * SECTION_SIZE + x - pos.x;
					if (format == PRE_JAVA_1_2)
						local = ((x - pos.x) * SECTION_SIZE + z - pos.z) * height + y - pos.y;

					IntType shift = (local % 2) * 4;
					uint16_t id = uint8_t(sourceBlocks.Value(local));
					uint8_t metadata = (uint8_t(sourceData.Value(local / 2)) >> shift) & 15;
					if (sourceAdd)
						id |= ((uint8_t(sourceAdd->Value(local / 2)) >> shift) & 15) << 8;

					if (filterEnabled)
					{
						BoolType known = false, retained = false;
						if (id < 256)
						{
							retained = Builder::filteredMcLegacyBlockIdObj[id][metadata] != nullptr;
							if (!retained)
							{
								StringType mcId = global::legacy_block_mc_id[id][metadata];
								known = Builder::mcBlockIdObjMap.contains(mcId);
							}
						}

						// Unknown IDs survive remove mode, matching palette-based exports
						if (!retained && (filterMode == e_block_filter_KEEP || known))
							continue;
					}

					IntType target = ((y - box.start.y) * size.z + z - box.start.z) * size.x + x - box.start.x;
					blocks[target] = int8_t(id & 255);
					data[target] = metadata;

					// MCEdit stores high block ID bits in an optional packed nibble array
					if (id > 255)
					{
						if (!schematic.HasKey("AddBlocks"))
						{
							NbtByteArray* add = new NbtByteArray;
							schematic.value["AddBlocks"] = add;
							add->value.Alloc((blocks.Size() + 1) / 2);
						}

						schematic.ByteArray("AddBlocks")[target / 2] |= int8_t((id >> 8) << ((target % 2) * 4));
					}
				}
			};

		if (format == PRE_JAVA_1_2)
			copyBlocks(exportData, chunkPos, 128);

		else if (exportData->HasKey("Sections"))
		{
			for (NbtCompound* section : exportData->List<TAG_COMPOUND, NbtCompound>("Sections"))
				copyBlocks(section, chunkPos + WorldVec(0, uint8_t(section->Byte("Y")) * SECTION_SIZE, 0), SECTION_SIZE);
		}

		if (!exportData->HasKey("TileEntities"))
			return;

		NbtList* entities = static_cast<NbtList*>(schematic.value.value("TileEntities"));
		for (NbtCompound* entity : exportData->List<TAG_COMPOUND, NbtCompound>("TileEntities"))
		{
			WorldVec pos = { entity->Int("x"), entity->Int("y"), entity->Int("z") };
			if (!box.Contains(pos))
				continue;

			IntType target = ((pos.y - box.start.y) * size.z + pos.z - box.start.z) * size.x + pos.x - box.start.x;
			uint16_t id = uint8_t(blocks[target]);
			if (schematic.HasKey("AddBlocks"))
				id |= ((uint8_t(schematic.ByteArray("AddBlocks")[target / 2]) >> ((target % 2) * 4)) & 15) << 8;

			if (filterEnabled && id == 0)
				continue;

			// Preserve the legacy payload and move its coordinates into selection space
			NbtCompound* output = new NbtCompound;
			entities->value.Alloc(entities->value.Size() + 1);
			entities->value[entities->value.Size() - 1] = output;
			output->value.swap(entity->value);
			output->Int("x") = int32_t(pos.x - box.start.x);
			output->Int("y") = int32_t(pos.y - box.start.y);
			output->Int("z") = int32_t(pos.z - box.start.z);
		}
	}
}
