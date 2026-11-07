#include "Schematic.hpp"
#include "Compress.hpp"

#include "Asset/DataStructure.hpp"
#include "Asset/Buffer.hpp"

namespace CppProject
{
	static QString SchematicGetDirection(const QString& name, const Matrix& transform)
	{
		const ArrType names = dir_names;
		IntType index = names.Find(StringType(name));
		if (index < 0)
			return name;

		// Convert between builder and scenery axes around the transform
		VecType dir = dir_get_vec3(index);
		dir = transform * VecType(dir.y, -dir.x, dir.z);
		return names.Value(vec3_get_dir(VecType(-dir.y, dir.x, dir.z), names)).Str();
	}

	static uint16_t SchematicGetTransformState(obj_block* block, IntType state, const Matrix& transform)
	{
		ArrType vars = block_get_state_id_state_vars(block->id, state);
		ArrType output = vars;

		// Convert a transform matrix to a predefined block state
		for (IntType i = 0; i + 1 < vars.Size(); i += 2)
		{
			QString name = vars.Value(i).Str(), value = vars.Value(i + 1).Str();
			QString newValue = value;

			if (name == "facing")
				newValue = SchematicGetDirection(value, transform);
			
			else if (name == "axis")
			{
				QString dir = SchematicGetDirection(value == "x" ? "east" : (value == "y" ? "up" : "south"), transform);
				if (dir == "east" || dir == "west")
					newValue = "x";
				else if (dir == "up" || dir == "down")
					newValue = "y";
				else
					newValue = "z";
			}
			else if (name == "rotation")
			{
				RealType angle = value.toInt() * 22.5 * DEGTORAD;
				VecType dir = transform * VecType(std::cos(angle), std::sin(angle), 0);
				int rot = int(std::round(std::atan2(dir.y, dir.x) * RADTODEG / 22.5));
				newValue = QString::number((rot % 16 + 16) % 16);
			}
			else if (name == "orientation")
			{
				QStringList dirs = value.split('_');
				for (QString& dir : dirs)
					dir = SchematicGetDirection(dir, transform);
				newValue = dirs.join('_');
			}
			else if (name == "north" || name == "south" || name == "east" || name == "west")
				output[i] = StringType(SchematicGetDirection(name, transform));

			output[i + 1] = StringType(newValue);
		}

		return (uint16_t)block_get_state_id(block->id, output);
	}

	// Create Schematic from world data provided via AddChunk/AddEntityRegion
	SchematicExport::SchematicExport(const WorldBox& selection, IntType dataVersion, BoolType skipIncompatible, BoolType applyFilter) :
		box(selection),
		dataVersion(dataVersion),
		legacy(dataVersion < Chunk::JAVA_1_13),
		skipIncompatible(skipIncompatible),
		applyFilter(applyFilter)
	{
		Initialize();
	}

	// Create Schematic from scenery/structure timelines and their modified blocks
	SchematicExport::SchematicExport(obj_timeline* timeline) :
		dataVersion(Chunk::JAVA_26_3),
		legacy(false),
		skipIncompatible(false),
		applyFilter(false),
		timeline(timeline),
		inverse(Matrix(timeline->matrix_render).GetInversed())
	{
		// Parse template repeat setting and scenery resource
		if (timeline->type == e_tl_type_SCENERY)
		{
			obj_template* temp = ObjTypeOpt(obj_template, timeline->temp);
			resource = temp ? ObjTypeOpt(obj_resource, temp->scenery) : nullptr;
			if (!resource || !tl_load_blocks(ScopeAny(timeline->id)))
				throw QString("Could not load the scenery source blocks");

			res_load_scenery_filter_mask(ScopeAny(resource->id));
			keepWater = !block_get_filtered(resource->id, FindMap(ObjType(obj_minecraft_assets, global::mc_assets)->block_name_map)->Value("water"));

			sourceSize = resource->scenery_size.ToVec();
			if (temp->block_repeat_enable)
				repeat = temp->block_repeat.ToVec();

			if (sourceSize.x <= 0 || sourceSize.y <= 0 || sourceSize.z <= 0 ||
				repeat.x <= 0 || repeat.y <= 0 || repeat.z <= 0)
				throw QString("Invalid scenery dimensions");

			VecType size(sourceSize.x * repeat.x, sourceSize.y * repeat.y, sourceSize.z * repeat.z);
			bounds.AddBounds({ VecType(0, 0, 0), size });
		}

		// Parse manually added blocks
		for (IntType i = 0; i < timeline->blocks_added.Size(); i++)
		{
			const ArrType& entry = timeline->blocks_added.vec.Value(i).Arr();
			IntType index = entry.IntValue(1);
			if (index < 0 || index >= timeline->blocks_added_palette.Size())
				throw QString("Invalid added block palette index");

			const ArrType& state = timeline->blocks_added_palette.vec.Value(index).Arr();
			Block addedBlock = {
				entry.Value(0).ToVec(),
				{ uint16_t(state.IntValue(0)), uint16_t(state.IntValue(1)), state.BoolValue(2) }
			};
			
			addedBlocks.append(addedBlock);
			if (addedBlock.state.blockId || addedBlock.state.waterlogged)
				bounds.AddBounds({ addedBlock.pos, addedBlock.pos + VecType(1, 1, 1) });
		}

		AddTimeline(timeline);

		if (bounds.empty)
			throw QString("No supported blocks to export");

		Initialize();
		AddResource();

		for (const Block& block : addedBlocks)
			AddBlock(block);

		for (const Block& block : parts)
			AddBlock(block);

		AddEntities();
	}

	QString SchematicExport::Extension() const
	{
		if (legacy)
			return ".schematic";

		return ".schem";
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

	void SchematicExport::Save(const QString& filename)
	{
		Gzip::WriteCompressed(Serialize(), filename);
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

	void SchematicExport::Initialize()
	{
		if (!timeline)
		{
			if (!box.active)
				throw QString("No world selection to export");

			box.Adjust();
		}

		WorldVec size;
		if (timeline)
		{
			WorldVec localSize = bounds.maxPoint - bounds.minPoint;
			size = { localSize.y, localSize.z, localSize.x };
		}
		else
			size = box.end - box.start;

		IntType maxDim;
		if (!legacy)
			maxDim = std::numeric_limits<uint16_t>::max();
		else
			maxDim = std::numeric_limits<int16_t>::max();

		if (size.x <= 0 || size.y <= 0 || size.z <= 0 ||
			size.x > maxDim || size.y > maxDim || size.z > maxDim)
			throw QString("Selection dimensions exceed the schematic format limits");

		IntType volume = size.x * size.y * size.z;
		if (volume > std::numeric_limits<int32_t>::max())
			throw QString("Selection volume exceeds the schematic format limits");

		if (timeline)
			box = { { 0, 0, 0 }, size };

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
		if (!legacy)
		{
			NbtIntArray* offset = new NbtIntArray;
			schematic->value["Offset"] = offset;
			offset->value.Alloc(3);

			palette = new NbtCompound;
			palette->value["minecraft:air"] = new NbtInt(0);

			NbtCompound* blocks = new NbtCompound;
			schematic->value["Blocks"] = blocks;
			blocks->value["Palette"] = palette;
			indices.Alloc(volume);

			entities = new NbtList(TAG_COMPOUND);
			blocks->value["BlockEntities"] = entities;
			schematic->value["Entities"] = new NbtList(TAG_COMPOUND);
		}
		else
		{
			schematic->value["Materials"] = new NbtString("Alpha");

			NbtByteArray* blocks = new NbtByteArray;
			NbtByteArray* data = new NbtByteArray;
			schematic->value["Blocks"] = blocks;
			schematic->value["Data"] = data;

			blocks->value.Alloc(volume);
			data->value.Alloc(volume);

			schematic->value["Entities"] = new NbtList(TAG_COMPOUND);
			schematic->value["TileEntities"] = new NbtList(TAG_COMPOUND);
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

	void SchematicExport::AddResource()
	{
		if (!resource)
			return;

		// Add source blocks from the grid of block meshes in the resource
		for (IntType m = 0; m < resource->block_meshes.Size(); m++)
		{
			obj_block_mesh* mesh = ObjTypeOpt(obj_block_mesh, resource->block_meshes.Value(m));
			if (!mesh)
				continue;

			Buffer* entries = FindBuffer(mesh->block_palette_buffer);
			Buffer* grid = FindBuffer(mesh->block_grid_buffer);
			if (!entries || !grid || !entries->data.Size() || entries->data.Size() % 4)
				throw QString("Missing or invalid source block data");

			WorldVec size = mesh->block_grid_size;
			IntType count = entries->data.Size() / 4, total = size.x * size.y * size.z;
			int bits = 0;
			while ((quint64(1) << bits) < quint64(count))
				bits++;
			
			IntType gridBytes = (total * bits + 7) / 8;
			if (count > total || gridBytes + (count + 7) / 8 > grid->data.Size())
				throw QString("Invalid source block grid");

			QVector<uint32_t> remap;
			QVector<BoolType> resolve;
			for (IntType p = 0; p < count; p++)
			{
				const uchar* entry = entries->data.Data() + p * 4;
				BuilderState state = {
					uint16_t(entry[0] | (entry[1] << 8)),
					uint16_t(entry[2] | (entry[3] << 8)),
					(grid->data[gridBytes + p / 8] & (1 << (p % 8))) != 0
				};
				obj_block* block = state.blockId ? ObjTypeOpt(obj_block, global::block_objs.Value(state.blockId)) : nullptr;
				BoolType connected = (resource->scenery_legacy && block && block->has_connect && !block_get_filtered(resource->id, block->id));
				resolve.append(connected);
				remap.append(connected ? 0 : GetPaletteIndex(state));
			}

			WorldVec meshNum = resource->block_meshes_num;
			WorldVec origin = {
				(m % meshNum.x) * block_mesh_size,
				((m / meshNum.x) % meshNum.y) * block_mesh_size,
				(m / (meshNum.x * meshNum.y)) * block_mesh_size
			};
			for (IntType p = 0; p < total; p++)
			{
				IntType bit = p * bits;
				quint64 packed = 0;
				for (int b = 0; b < (bit % 8 + bits + 7) / 8; b++)
					packed |= quint64(grid->data[bit / 8 + b]) << (b * 8);
				
				IntType index = (packed >> (bit % 8)) & ((quint64(1) << bits) - 1);
				if (index >= count)
					throw QString("Invalid source block palette index");

				WorldVec source = origin + WorldVec(p % size.x, (p / size.x) % size.y, p / (size.x * size.y));
				WorldVec pos = { source.y, sourceSize.y - 1 - source.x, source.z };
				for (IntType z = 0; z < repeat.z; z++)
				for (IntType y = 0; y < repeat.y; y++)
				for (IntType x = 0; x < repeat.x; x++)
				{
					WorldVec target = pos + sourceSize * WorldVec(x, y, z);
					uint32_t value = remap[index];

					if (resolve[index])
					{
						// Legacy doors and double chests share state across neighboring blocks
						ArrType state = block_meshes_get_block(Scope<obj_timeline>(timeline), target.x, target.y, target.z, false, true);
						value = GetPaletteIndex({ uint16_t(state.IntValue(0)), uint16_t(state.IntValue(1)), state.BoolValue(2) });
					}

					indices[GetOffset(target)] = value;
				}
			}
		}

		// Timeline parts replace their source blocks even after moving or deletion
		List* sources = FindList(resource->scenery_tl_list);
		if (!sources)
			return;

		for (const List::ListValue& value : sources->vec)
		{
			obj_block_tl* blockTl = ObjType(obj_block_tl, value.value);
			obj_block* block = ObjTypeOpt(obj_block, blockTl->block);
			if (!block || block->tl_model_double)
				continue;

			IntType state = block_get_state_id(block->id, blockTl->block_build_state);
			VecType pos = (blockTl->position.ToVec() - block_get_timeline_position(block->id, state)) / block_size_;
			WorldVec origin = { IntType(std::round(pos.y)), sourceSize.y - 1 - IntType(std::round(pos.x)), IntType(std::round(pos.z)) };
			
			for (const Block& connectedBlocks : GetConnectedBlocks(block, state))
			for (IntType z = 0; z < repeat.z; z++)
			for (IntType y = 0; y < repeat.y; y++)
			for (IntType x = 0; x < repeat.x; x++)
			{
				// Copy block, keeping source waterlogged flag
				WorldVec target = VecType(origin) + connectedBlocks.pos + VecType(sourceSize * WorldVec(x, y, z));
				ArrType meshBlock = block_meshes_get_block(Scope<obj_timeline>(timeline), target.x, target.y, target.z);
				AddBlock({ VecType(target), { 0, 0, keepWater && meshBlock.BoolValue(2) } });
			}
		}
	}

	void SchematicExport::AddTimeline(obj_timeline* parent)
	{
		List* children = FindList(parent->tree_list);
		if (!children)
			return;

		for (const List::ListValue& child : children->vec)
		{
			obj_timeline* part = ObjTypeOpt(obj_timeline, child.value);
			if (!part || part->delete_ready)
				continue;

			if (part->type == e_tl_type_BLOCK || part->type == e_tl_type_SPECIAL_BLOCK)
			{
				Object* temp = ObjOpt(part->temp);
				if (!temp)
					temp = part;
				
				obj_model* model = nullptr;
				if (part->type == e_tl_type_SPECIAL_BLOCK)
				{
					obj_minecraft_assets* assets = ObjType(obj_minecraft_assets, global::mc_assets);
					Map* models = FindMap(assets->model_name_map);
					model = ObjTypeOpt(obj_model, models->Value(temp->GetVarRef(M_model_name)));
				}

				// Painting
				if (model && model->entity_tl_type == "painting")
				{
					Matrix transform = Matrix(part->matrix_render) * inverse;
					VecType origin = VecType(transform.m[12], transform.m[13], transform.m[14]) / block_size_;
					VecType direction = transform * VecType(1, 0, 0);
					IntType facing = (IntType(std::round(std::atan2(direction.y, direction.x) * RADTODEG / 90)) + 5) % 4;
					obj_model_file* file = ObjTypeOpt(obj_model_file, temp->GetVarRef(M_model_file));
					VecType extent = file ? VecType(file->bounds_parts_end) - VecType(file->bounds_parts_start) : VecType(block_size_, block_size_, block_size_);
					IntType width = std::max(IntType(1), IntType(std::round(extent.x / block_size_)));
					IntType height = std::max(IntType(1), IntType(std::round(extent.z / block_size_)));
					VecType pos(std::round(origin.x * 2) / 2, std::round(origin.y * 2) / 2, std::round(origin.z) + height / 2.0);

					switch (facing)
					{
						case 0: pos.x += 1.0 / 32; break;
						case 1: pos.y += 1.0 / 32; break;
						case 2: pos.x -= 1.0 / 32; break;
						case 3: pos.y -= 1.0 / 32; break;
					}

					paintings.append({ part, pos, facing, width, height });

					VecType blockPos(std::floor(pos.x), std::ceil(pos.y) - 1, std::floor(pos.z));
					bounds.AddBounds({ blockPos, blockPos + VecType(1, 1, 1) });
				}

				// Block timeline
				else
				{
					VarType data = tl_get_build_block(ScopeAny(part->id));
					if (!data.IsArray())
						continue;

					IntType state = data.Arr().IntValue(1);
					obj_block* block = ObjType(obj_block, global::block_objs.Value(data.Arr().IntValue(0)));
					VecType pos = block_get_timeline_position(block->id, state);

					Matrix base = Matrix::Translation(pos.y, block_size_ - pos.x, pos.z);
					VecType rotpoint(block_half_size, block_half_size, 0);
					if (block->timeline)
					{
						base = Matrix(block_get_timeline_matrix(block->id, state));
						rotpoint = block_get_timeline_rot_point(block->id, state);
					}
					base = Matrix::Translation(-rotpoint) * base;

					Matrix transform = base.GetInversed() * Matrix(part->matrix_render) * inverse;
					WorldVec repeat = { 1, 1, 1 };
					if (part->type == e_tl_type_BLOCK && temp->GetVarRef(M_block_repeat_enable))
						repeat = temp->GetVarRef(M_block_repeat).ToVec();

					// Transform block centers, retaining the nearest Minecraft orientation
					for (IntType z = 0; z < repeat.z; z++)
					for (IntType y = 0; y < repeat.y; y++)
					for (IntType x = 0; x < repeat.x; x++)
					for (Block addedBlock : GetConnectedBlocks(block, state))
					{
						VecType center = (addedBlock.pos + VecType(x + 0.5, y + 0.5, z + 0.5)) * block_size_;
						VecType transformed = transform * VecType(center.x, center.y, center.z, 1);
						addedBlock.pos = {
							std::floor(transformed.x / block_size_ + 0.000001),
							std::floor(transformed.y / block_size_ + 0.000001),
							std::floor(transformed.z / block_size_ + 0.000001)
						};

						obj_block* connectedBlock = ObjType(obj_block, global::block_objs.Value(addedBlock.state.blockId));
						addedBlock.state.stateId = SchematicGetTransformState(connectedBlock, addedBlock.state.stateId, transform);
						addedBlock.timeline = part;

						if (connectedBlock->tl_type == "banner")
							addedBlock.state.stateId = uint16_t(block_set_state_id_value(connectedBlock->id, addedBlock.state.stateId, StringType("color"), minecraft_get_dye(temp->GetVarRef(M_pattern_base_color))).ToInt());

						parts.append(addedBlock);
						bounds.AddBounds({ addedBlock.pos, addedBlock.pos + VecType(1, 1, 1) });
					}
				}
			}

			AddTimeline(part);
		}
	}

	void SchematicExport::AddBlock(const Block& block)
	{
		IntType offset = GetOffset(block.pos);
		if (offset < 0)
			return;

		BuilderState state = block.state;
		if (block.timeline)
		{
			// Preserve waterlogged flag
			WorldVec pos = block.pos;
			ArrType meshBlock = block_meshes_get_block(Scope<obj_timeline>(timeline), pos.x, pos.y, pos.z);
			obj_block* meshBlockObj = ObjTypeOpt(obj_block, global::block_objs.Value(meshBlock.IntValue(0)));
			state.waterlogged = keepWater &&
				(meshBlock.BoolValue(2) || (meshBlockObj && meshBlockObj->name == StringType("water"))) &&
				(!resource || !meshBlockObj || !block_get_filtered(resource->id, meshBlockObj->id));

			indices[offset] = GetPaletteIndex(state, false);
		}
		else
			indices[offset] = GetPaletteIndex(state, true);

		addedBlockMap.remove(offset);
		if (block.timeline)
			addedBlockMap.insert(offset, block);
	}

	void SchematicExport::AddEntities()
	{
		NbtList* blockEntities = static_cast<NbtList*>(schematic->Compound("Blocks")->value.value("BlockEntities"));
		NbtList* entities = static_cast<NbtList*>(schematic->value.value("Entities"));

		// Add signs, banners and decorated pots
		for (const Block& addedBlock : addedBlockMap)
		{
			obj_timeline* part = addedBlock.timeline;
			obj_block* block = ObjType(obj_block, global::block_objs.Value(addedBlock.state.blockId));
			if (block->tl_type != "sign" && block->tl_type != "banner" && block->name != "decorated_pot")
				continue;

			Object* temp = ObjOpt(part->temp);
			if (!temp)
				temp = part;

			NbtCompound* entity = new NbtCompound;
			IntType index = blockEntities->value.Size();
			blockEntities->value.Alloc(index + 1);
			blockEntities->value[index] = entity;

			NbtIntArray* pos = new NbtIntArray;
			pos->value.Alloc(3);
			pos->value[0] = int32_t(bounds.maxPoint.y - 1 - addedBlock.pos.y);
			pos->value[1] = int32_t(addedBlock.pos.z - bounds.minPoint.z);
			pos->value[2] = int32_t(addedBlock.pos.x - bounds.minPoint.x);
			entity->value["Pos"] = pos;

			NbtCompound* data = new NbtCompound;
			entity->value["Data"] = data;

			if (block->tl_type == "sign")
			{
				entity->value["Id"] = new NbtString(block->name.Str().Contains("hanging") ? "minecraft:hanging_sign" : "minecraft:sign");
				data->value["front_text"] = GetSignText(part, false);
				data->value["back_text"] = GetSignText(part, true);
			}
			else if (block->tl_type == "banner")
			{
				entity->value["Id"] = new NbtString("minecraft:banner");

				const ArrType& patternList = temp->GetArrRef(M_pattern_pattern_list);
				const ArrType& colorList = temp->GetArrRef(M_pattern_color_list);
				NbtList* patterns = new NbtList(TAG_COMPOUND);
				IntType count = std::min(patternList.Size(), colorList.Size());
				data->value["patterns"] = patterns;
				patterns->value.Alloc(count);
				
				for (IntType i = 0; i < count; i++)
				{
					NbtCompound* pattern = new NbtCompound;
					StringType name = patternList.Value(i).Str();
					patterns->value[i] = pattern;
					pattern->value["pattern"] = new NbtString(name.Contains(":") ? name : StringType("minecraft:") + name);
					pattern->value["color"] = new NbtString(minecraft_get_dye(colorList.IntValue(i)));
				}
			}
			else if (block->name == "decorated_pot")
			{
				entity->value["Id"] = new NbtString("minecraft:decorated_pot");

				NbtList* sherds = new NbtList(TAG_STRING);
				data->value["sherds"] = sherds;
				sherds->value.Alloc(4);

				VarType modelState = temp->GetVarRef(M_model_state);
				Map* names = FindMap(global::minecraft_sherd_map);
				const char* sides[] = { "sherd_front", "sherd_left", "sherd_right", "sherd_back" };
				for (int side = 0; side < 4; side++)
				{
					VarType value = state_vars_get_value(modelState, StringType(sides[side]));
					StringType item = "minecraft:brick";

					for (VarType key = names->GetFirstKey(); !key.IsUndefined(); key = names->GetNextKey(key))
					{
						if (names->Value(key) == value)
						{
							item = key.Str();
							break;
						}
					}

					sherds->value[side] = new NbtString(item);
				}
			}
		}

		// Add paintings
		for (const Painting& painting : paintings)
		{
			Object* settings = ObjOpt(painting.timeline->temp);
			if (!settings)
				settings = painting.timeline;
			
			VarType variant = state_vars_get_value(settings->GetVarRef(M_model_state), StringType("variant"));
			if (!variant.IsString())
				continue;

			IntType facing = painting.facing;
			RealType x = bounds.maxPoint.y - painting.pos.y;
			RealType y = painting.pos.z - bounds.minPoint.z;
			RealType z = painting.pos.x - bounds.minPoint.x;

			NbtCompound* entity = new NbtCompound;
			IntType index = entities->value.Size();
			entities->value.Alloc(index + 1);
			entities->value[index] = entity;
			entity->value["Id"] = new NbtString("minecraft:painting");

			NbtList* pos = new NbtList(TAG_DOUBLE);
			entity->value["Pos"] = pos;
			pos->value.Alloc(3);
			pos->value[0] = new NbtDouble(x);
			pos->value[1] = new NbtDouble(y);
			pos->value[2] = new NbtDouble(z);

			NbtCompound* data = new NbtCompound;
			entity->value["Data"] = data;

			QString name = variant.Str();
			name.remove(QRegularExpression("^painting_"));
			data->value["variant"] = new NbtString(name.contains(':') ? name : "minecraft:" + name);
			data->value["facing"] = new NbtByte(facing);

			NbtIntArray* blockPos = new NbtIntArray;
			data->value["block_pos"] = blockPos;
			blockPos->value.Alloc(3);

			RealType offset = (painting.width % 2 == 0 ? 0.5 : 0);
			blockPos->value[0] = int32_t(std::floor(x + (facing == 0 ? -offset : (facing == 2 ? offset : 0))));
			blockPos->value[1] = int32_t(std::floor(y - (painting.height % 2 == 0 ? 0.5 : 0)));
			blockPos->value[2] = int32_t(std::floor(z + (facing == 1 ? -offset : (facing == 3 ? offset : 0))));
		}
	}

	void SchematicExport::AddEntities(NbtCompound& chunk)
	{
		NbtCompound* source = &chunk;
		if (chunk.HasKey("Level"))
			source = chunk.Compound("Level");

		StringType entitiesName = source->HasKey("Entities") ? "Entities" : "entities";
		if (!source->HasKey(entitiesName))
			return;

		NbtList* entities = static_cast<NbtList*>(schematic->value.value("Entities"));

		for (NbtCompound* entity : source->List<TAG_COMPOUND, NbtCompound>(entitiesName))
		{
			if (entity->GetType("id") != TAG_STRING || entity->GetType("Pos") != TAG_LIST)
				continue;

			StringType id = entity->String("id");

			// Filter unsupported entities when creating a resource snapshot
			StringType name = id.ToLower().Replaced("minecraft:", "");
			if (!exportOnly && !DsMap(ObjType(obj_minecraft_assets, global::mc_assets)->entity_model_map).Contains(name))
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
			entities->value.Alloc(entities->value.Size() + 1);
			entities->value[entities->value.Size() - 1] = output;

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

			if (!legacy)
			{
				delete output->value.take("id");

				NbtCompound* payload = new NbtCompound;
				payload->value.swap(output->value);
				output->value["Id"] = new NbtString(id);
				output->value["Pos"] = localPos;
				output->value["Data"] = payload;
			}
			else
			{
				output->value["Pos"] = localPos;

				for (const char* axis : { "TileX", "TileY", "TileZ" })
				{
					if (output->GetType(axis) != TAG_INT)
						continue;

					IntType start;
					if (axis[4] == 'X')
						start = box.start.x;
					else if (axis[4] == 'Y')
						start = box.start.y;
					else
						start = box.start.z;
					
					output->Int(axis) -= int32_t(start);
				}
			}
		}
	}

	IntType SchematicExport::GetOffset(const VecType& pos) const
	{
		VecType blockPos = pos - bounds.minPoint;
		WorldVec size = bounds.maxPoint - bounds.minPoint;

		if (blockPos.x < 0 || blockPos.y < 0 || blockPos.z < 0 ||
			blockPos.x >= size.x || blockPos.y >= size.y || blockPos.z >= size.z)
			return -1;

		return (blockPos.z * size.x + blockPos.x) * size.y + size.y - 1 - blockPos.y;
	}

	uint32_t SchematicExport::GetPaletteIndex(BuilderState state, BoolType filter)
	{
		// Apply resource block filter settings
		if (filter && resource)
		{
			if (state.blockId && block_get_filtered(resource->id, global::block_objs.Value(state.blockId)))
				state = {};

			if (!keepWater)
				state.waterlogged = false;
		}

		quint64 key = quint64(state.blockId) | (quint64(state.stateId) << 16) | (quint64(state.waterlogged) << 32);
		auto cached = paletteIndices.constFind(key);
		if (cached != paletteIndices.constEnd())
			return cached.value();

		QString name = state.waterlogged ? "minecraft:water" : "minecraft:air";
		QStringList properties;

		obj_block* block = state.blockId ? ObjTypeOpt(obj_block, global::block_objs.Value(state.blockId)) : nullptr;

		// Skip blocks marked as invisible by block timelines
		if (block && block->tl_mesh && block_get_state_id_value(block->id, state.stateId, StringType("visible")) == StringType("false"))
			block = nullptr;

		// Find Minecraft ID
		if (block && block->mc_ids.Size())
		{
			obj_minecraft_assets* assets = ObjType(obj_minecraft_assets, global::mc_assets);
			Map* idStateVarsMap = FindMap(block->id_state_vars_map);
			ArrType selectors;
			int best = -1;
			const ArrType dirNames = dir_names;

			for (IntType i = 0; i < block->mc_ids.Size(); i++)
			{
				StringType curId = block->mc_ids.Value(i).Str();
				if (!curId.Contains(":"))
					curId = StringType("minecraft:") + curId;

				ArrType vars;
				if (idStateVarsMap)
				{
					VarType match = idStateVarsMap->Value(curId);
					if (!match.IsArray() && match != null_)
						continue;

					// Empty identifier selectors are stored as null
					if (match.IsArray())
						vars = match.Arr();

					// Horizontal facing selectors supply an importer default
					IntType facing = vars.Find(StringType("facing"));
					if (facing > -1)
					{
						IntType index = dirNames.Find(vars.Value(facing + 1));
						if (index >= XP && index <= YN)
							vars[facing + 1] = ArrType::From({ dirNames.Value(XP), dirNames.Value(XN), dirNames.Value(YP), dirNames.Value(YN) });
					}

					if (!state_vars_match_state_id(vars, block->id, state.stateId))
						continue;
				}

				// Prefer current identifiers over legacy aliases of the same state
				int score = int(vars.Size());
				if (block->mc_ids.Value(i).Str() == block->name)
					score++;

				if (file_exists_lib(global::load_assets_startup_dir + mc_blockstates_directory + block->mc_ids.Value(i).Str() + ".json"))
					score += 1024;

				if (score > best)
				{
					best = score;
					name = curId;
					selectors = vars;
				}
			}

			// Export block properties excluding internal states and identifier selectors
			ArrType vars = block_get_state_id_state_vars(block->id, state.stateId);
			for (IntType i = 0; best >= 0 && i + 1 < vars.Size(); i += 2)
			{
				QString property = vars.Value(i).Str();
				BoolType facing = property == "facing" && state_vars_get_value(selectors, vars.Value(i)).IsArray();
				if (property == "visible" || property == "double" || property == "variant" || property == "waterlogged" ||
					(property == "snowy" && ds_list_find_index(assets->block_snowy_list, StringType(name)) < 0) ||
					(block->type == "door" && (property == "location" || property == "direction")) ||
					(!facing && state_vars_get_value(selectors, vars.Value(i)) != null_))
					continue;

				properties.append(property + "=" + vars.Value(i + 1).Str().QStr());
			}

			// Preserve wet/dry overrides without adding properties to water-only blocks
			if (best >= 0 && ds_list_find_index(assets->block_waterlogged_list, StringType(name)) < 0 &&
				(state.waterlogged != block->waterlogged || !block_get_state_id_value(block->id, state.stateId, StringType("waterlogged")).IsUndefined()))
				properties.append(state.waterlogged ? "waterlogged=true" : "waterlogged=false");
		}

		// Construct final palette entry
		properties.sort();
		if (!properties.isEmpty())
			name += "[" + properties.join(',') + "]";

		// Insert into palette or fetch existing index
		StringType entry(name);
		uint32_t index;
		if (palette->HasKey(entry))
			index = palette->Int(entry);
		else
		{
			index = palette->value.size();
			palette->value[entry] = new NbtInt(index);
		}

		paletteIndices.insert(key, index);

		return index;
	}

	QVector<SchematicExport::Block> SchematicExport::GetConnectedBlocks(obj_block* block, IntType state)
	{
		QVector<Block> connectedBlocks;
		ArrType connected = block_build_get_connect(block->id, state, VecType(0, 0, 0));
		for (IntType i = 0; i < connected.Size(); i++)
		{
			const ArrType& blockData = connected.vec.Value(i).Arr();
			connectedBlocks.append({
				blockData.Value(0).ToVec(),
				{ uint16_t(blockData.IntValue(1)), uint16_t(blockData.IntValue(2)), false }
			});
		}

		return connectedBlocks;
	}

	NbtCompound* SchematicExport::GetSignText(obj_timeline* sign, BoolType back)
	{
		QString text;
		IntType color = 0;
		BoolType glowing = false;
		Matrix signInverse = Matrix(sign->matrix_render).GetInversed();

		List* children = FindList(sign->part_list);
		if (children)
		{
			for (const List::ListValue& child : children->vec)
			{
				obj_timeline* tl = ObjType(obj_timeline, child.value);
				if (tl->type != e_tl_type_TEXT)
					continue;

				Matrix relative = Matrix(tl->matrix_render) * signInverse;
				VecType normal = relative * VecType(0, 1, 0);
				if ((normal.y < 0) == back)
				{
					text = tl->value[e_value_TEXT].Str();
					color = tl->value[e_value_RGB_MUL];
					glowing = tl->value[e_value_EMISSIVE].ToReal() > 0;
					break;
				}
			}
		}

		NbtCompound* data = new NbtCompound;
		NbtList* messages = new NbtList(TAG_COMPOUND);
		data->value["messages"] = messages;
		messages->value.Alloc(4);

		QStringList lines = text.split('\n');
		for (int i = 0; i < 4; i++)
		{
			NbtCompound* component = new NbtCompound;
			component->value["text"] = new NbtString(lines.value(i));
			messages->value[i] = component;
		}

		data->value["color"] = new NbtString(minecraft_get_dye(color, glowing));
		data->value["has_glowing_text"] = new NbtByte(glowing);

		return data;
	}
}
