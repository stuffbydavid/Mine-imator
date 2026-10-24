#include "World/World.hpp"

#include "AppHandler.hpp"
#include "Asset/DataStructure.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Asset/Buffer.hpp"
#include "World/GZIP.hpp"

#define BLOCK_MESH_CACHE_ENABLED 1

namespace CppProject
{
	static constexpr uchar BLOCK_MESH_CACHE_FORMAT = 5;

	// 2.0 mesh cache uses untransformed vertices and a 32x32 static block sheet
	static constexpr uchar BLOCK_MESH_CACHE_FORMAT_LEGACY = 2;
	static constexpr IntType BLOCK_MESH_CACHE_LEGACY_SHEET_SIZE = 32;

	Heap<Section*> Builder::sections;
	WorldVec Builder::size, Builder::offset = { 0, 0, 0 }, Builder::sectionsDim;
	IntType Builder::sectionsXY;
	QHash<StringType, obj_block*> Builder::mcBlockIdObjMap, Builder::filteredMcBlockIdObjMap;
	QHash<StringType, ArrType> Builder::mcBlockIdStateVarsMap;
	Heap<obj_block*> Builder::blocks;
	Heap<obj_block_render_model*> Builder::renderModels;
	obj_block* Builder::filteredMcLegacyBlockIdObj[256][16];

	void builder_create_buffers(Scope<obj_builder> self)
	{
		// Get dimensions from given x/y/z size with offset
		Builder::size = {
			self->build_size.Value(X_).ToInt(),
			self->build_size.Value(Y_).ToInt(),
			self->build_size.Value(Z_).ToInt()
		};
		WorldVec sizeOffset = Builder::size + Builder::offset;
		Builder::sectionsDim = {
			(IntType)ceilf((RealType)sizeOffset.x / SECTION_SIZE),
			(IntType)ceilf((RealType)sizeOffset.y / SECTION_SIZE),
			(IntType)ceilf((RealType)sizeOffset.z / SECTION_SIZE)
		};

		Builder::sectionsXY = Builder::sectionsDim.x * Builder::sectionsDim.y;
		IntType sectionsTotal = Builder::sectionsDim.x * Builder::sectionsDim.y * Builder::sectionsDim.z;
		Builder::sections.Alloc(sectionsTotal);

		// Add empty sections if no world is loaded
		if (!World::regions.size())
		{
			// Size of last section(s) in each axis
			IntType lastSize[3];
			for (IntType a = X_; a <= Z_; a++)
			{
				lastSize[a] = self->build_size.Value(a).ToInt() % SECTION_SIZE;
				if (!lastSize[a])
					lastSize[a] = SECTION_SIZE;
			}

			// Check if single block
			BuilderState singleEntry;
			if (self->build_single_block != null_ && !is_undefined(self->build_single_block))
				singleEntry = {
					(uint16_t)ObjType(obj_block, self->build_single_block)->block_id,
					(uint16_t)self->build_single_stateid,
					false
				};

			IntType s = 0;
			for (IntType z = 0; z < Builder::sectionsDim.z; z++)
			for (IntType y = 0; y < Builder::sectionsDim.y; y++)
			for (IntType x = 0; x < Builder::sectionsDim.x; x++, s++)
			{
				Section* section = new Section(
					{ x * SECTION_SIZE,
					  z * SECTION_SIZE,
					  y * SECTION_SIZE },
					{ (x < Builder::sectionsDim.x - 1) ? SECTION_SIZE : lastSize[X_],
					  (z < Builder::sectionsDim.z - 1) ? SECTION_SIZE : lastSize[Z_],
					  (y < Builder::sectionsDim.y - 1) ? SECTION_SIZE : lastSize[Y_] }
				);

				if (self->build_single_block != null_)
					section->AddBuilderState(singleEntry);

				Builder::sections[s] = section;
			}
		}
	}

	void builder_thread_set_pos(Scope<obj_builder_thread> self, IntType position)
	{
		// Separate function to make sure the integer mod/division are used
		IntType width = self->build_size.IntValue(X_);
		IntType height = self->build_size.IntValue(Y_);
		self->build_pos_index = position;
		self->build_pos[X_] = position % width;
		self->build_pos[Y_] = (position / width) % height;
		self->build_pos[Z_] = position / self->build_size_xy;

		if (self->block_meshes.Size())
		{
			IntType index =
				((self->build_pos.IntValue(Z_) / block_mesh_size) * self->block_meshes_size.Value(Y_) +
				(self->build_pos.IntValue(Y_) / block_mesh_size)) * self->block_meshes_size.Value(X_) +
				(self->build_pos.IntValue(X_) / block_mesh_size);
			
			self->block_mesh = self->block_meshes.Value(index);
		}
	}

	BoolType builder_read_schematic_data(Scope<obj_builder> self, IntType version, IntType mapId,
		IntType paletteIndicesId, IntType blockAmount)
	{
		Map* map = FindMap(mapId);
		Map* indicesMap = FindMap(paletteIndicesId);
		Buffer* buffer = FindBuffer(global::buffer_current);
		StringType key = (version >= 3 ? "Data" : "BlockData");

		if (!map || !indicesMap || indicesMap->GetType() != Map::HASH_INT || !buffer)
		{
			log({ "Schematic error", "Block data array not found or has invalid type" });
			return false;
		}

		VarType readPosValue = map->Value(key);
		VarType lengthValue = map->Value(key + "_NBT_length");
		VarType dataType = map->Value(key + "_NBT_type");
		BoolType intArray = dataType == e_nbt_TAG_INT_ARRAY;

		if (!readPosValue.IsAnyReal() || !lengthValue.IsAnyReal() ||
			(!intArray && dataType != e_nbt_TAG_BYTE_ARRAY))
		{
			log({ "Schematic error", "Block data array not found or has invalid type" });
			return false;
		}

		IntType readPos = readPosValue.ToInt();
		IntType length = lengthValue.ToInt();
		IntType sourceSize = buffer->data.Size();
		IntType sourceStride = intArray ? 4 : 1;

		if (readPos < 0 || readPos > sourceSize || length < blockAmount ||
			length > (sourceSize - readPos) / sourceStride)
		{
			log({ "Schematic error", "Block data array is truncated" });
			return false;
		}

		BoolType rawBytes = (version == 1 && !intArray && length == blockAmount);
		IntHashMap* indices = static_cast<IntHashMap*>(indicesMap);
		IntType paletteSize = indices->GetSize();
		QVector<IntType> denseIndices(paletteSize, -1);
		BoolType dense = true;

		for (auto it = indices->hash.constBegin(); it != indices->hash.constEnd(); ++it)
		{
			if (it.key() < 0 || it.key() >= paletteSize || !it.value().value.IsAnyReal())
			{
				dense = false;
				break;
			}

			denseIndices[it.key()] = it.value().value.ToInt();
		}

		IntType outputStride = paletteSize > 256 ? 4 : 1;
		if (blockAmount < 0 || blockAmount > (std::numeric_limits<IntType>::max() - sourceSize) / outputStride)
		{
			log({ "Schematic error", "Block data array is truncated" });
			return false;
		}

		self->sch_blockdata_ints = outputStride == 4;
		self->sch_blockdata_array = sourceSize;
		buffer->data.Alloc(sourceSize + blockAmount * outputStride, false);

		uchar* data = buffer->data.data;
		IntType endPos = readPos + length * sourceStride;
		IntType writePos = sourceSize;

		for (IntType i = 0; i < blockAmount; i++)
		{
			uint32_t value = 0;
			if (intArray)
			{
				value = ((uint32_t)data[readPos] << 24) | ((uint32_t)data[readPos + 1] << 16) |
					((uint32_t)data[readPos + 2] << 8) | data[readPos + 3];
				readPos += 4;
			}
			else if (rawBytes)
				value = data[readPos++];
			else
			{
				for (IntType b = 0;; b++)
				{
					if (readPos >= endPos || b == 5)
					{
						log({ "Schematic error", "Truncated or oversized block varint" });
						return false;
					}

					uchar byte = data[readPos++];
					if (b == 4 && byte > 7)
					{
						log({ "Schematic error", "Block varint exceeds a non-negative integer" });
						return false;
					}

					value |= (uint32_t)(byte & 127) << (b * 7);
					if (byte < 128)
						break;
				}
			}

			IntType slot = -1;
			if (dense)
			{
				if (value < (uint32_t)paletteSize)
					slot = denseIndices[value];
			}
			else
			{
				auto it = indices->hash.constFind(value);
				if (it != indices->hash.constEnd() && it.value().value.IsAnyReal())
					slot = it.value().value.ToInt();
			}

			if (slot < 0 || slot >= paletteSize)
			{
				log({ "Schematic error", "Block data references a missing palette entry" });
				return false;
			}

			if (outputStride == 4)
			{
				data[writePos++] = (uchar)(slot >> 24);
				data[writePos++] = (uchar)(slot >> 16);
				data[writePos++] = (uchar)(slot >> 8);
				data[writePos++] = (uchar)slot;
			}
			else
				data[writePos++] = (uchar)slot;
		}

		if (readPos != endPos)
		{
			log({ "Schematic error", "Block data contains more entries than the schematic size" });
			return false;
		}

		return true;
	}

	void builder_read_schematic_blocks(Scope<obj_builder> self)
	{
		IntType numTimelines = 0;
		Buffer* buffer = FindBuffer(global::buffer_current);

		debug_timer_start();
		builder_start(self);

		// Schematic palette from VarType to raw C++ types
		Heap<IntType> paletteBlocks, paletteStateIds;
		Heap<BoolType> paletteWaterlogged;
		if (self->sch_palette_blocks.IsArray())
		{
			IntType size = self->sch_palette_blocks.Arr().Size();
			paletteBlocks.Alloc(size);
			paletteStateIds.Alloc(size);
			paletteWaterlogged.Alloc(size);

			for (IntType i = 0; i < size; i++)
			{
				paletteBlocks[i] = self->sch_palette_blocks[i];
				paletteStateIds[i] = self->sch_palette_state_ids[i];
				paletteWaterlogged[i] = self->sch_palette_waterlogged[i];
			}
		}

		IntType blockDataArray = self->sch_blockdata_array;
		IntType legacyBlockArray = self->sch_legacy_blocks_array;
		IntType legacyDataArray = self->sch_legacy_data_array;
		IntType legacyAddArray = self->sch_legacy_add_array;

		// Populate sections with schematic data
		#pragma OPENMP_FOR(1) reduction(+:numTimelines)
		for (IntType s = 0; s < Builder::sections.Size(); s++)
		{
			Section* section = Builder::sections[s];

			IntType b = 0;
			for (IntType sz = 0; sz < section->builder.size.z; sz++)
			for (IntType sy = 0; sy < section->builder.size.y; sy++)
			for (IntType sx = 0; sx < section->builder.size.x; sx++, b++)
			{
				// Get block position
				IntType bx = section->builder.pos.x + sx;
				IntType by = section->builder.pos.y + sy;
				IntType bz = section->builder.pos.z + sz;
				IntType bufferPos = bz * (IntType)self->build_size_xy + by * Builder::size.x + bx;

				obj_block* block = nullptr;
				BuilderState state;

				if (!self->builder_scenery_legacy)
				{
					// Parse index
					IntType paletteIndex;
					if (self->sch_blockdata_ints) // Big endian indices
					{
						IntType off = blockDataArray + (bufferPos << 2); // array + pos * 4
						uint8_t b1 = buffer->data[off];
						uint8_t b2 = buffer->data[off + 1];
						uint8_t b3 = buffer->data[off + 2];
						uint8_t b4 = buffer->data[off + 3];

						paletteIndex = (b1 << 24) + (b2 << 16) + (b3 << 8) + b4;
					}
					else // uchar indices
						paletteIndex = buffer->data[blockDataArray + bufferPos];

					// Get block from instance id in schematic palette
					if (paletteIndex >= 0 && paletteIndex < paletteBlocks.Size())
					{
						block = ObjTypeOpt(obj_block, paletteBlocks[paletteIndex]);

						state.stateId = paletteStateIds[paletteIndex];
						state.waterlogged = paletteWaterlogged[paletteIndex];
					}
				}
				else
				{
					// Get block from legacy id+data
					IntType legacyId = buffer->data[legacyBlockArray + bufferPos];
					if (legacyAddArray != null_)
					{
						uint8_t high = buffer->data[legacyAddArray + bufferPos / 2];
						if (bufferPos % 2)
							legacyId += (high >> 4) << 8;
						else
							legacyId += (high & 15) << 8;
					}

					if (legacyId > 0 && legacyId < 256 && global::legacy_block_set[legacyId])
					{
						uint8_t legacyData = buffer->data[legacyDataArray + bufferPos] % 16;
						block = ObjTypeOpt(obj_block, global::legacy_block_obj[legacyId][legacyData]);

						state.stateId = global::legacy_block_state_id[legacyId][legacyData].ToInt();
					}
				}

				if (block)
				{
					state.blockId = block->block_id;
					if (block->timeline)
						numTimelines++;
				}

				section->builder.paletteIndices[b] = section->AddBuilderState(state);
			}

			section->builder.palette.Trim();
		}

		self->sch_timeline_amount = numTimelines;
		debug_timer_stop("Parse blocks");
	}

	void builder_read_blocks_file(Scope<obj_builder> self)
	{
		IntType numTimelines = 0;
		Buffer* buffer = FindBuffer(global::buffer_current);

		debug_timer_start();

		self->file_map = buffer_read_string_short_be();
		self->build_size[Y_] = buffer_read_short_be();
		self->build_size[X_] = buffer_read_short_be();
		self->build_size[Z_] = buffer_read_short_be();
		IntType blockData = buffer->pos;

		builder_start(self);

		// Populate sections with legacy blocks
		#pragma OPENMP_FOR(1) reduction(+:numTimelines)
		for (IntType s = 0; s < Builder::sections.Size(); s++)
		{
			Section* section = Builder::sections[s];

			IntType b = 0;
			for (IntType sz = 0; sz < section->builder.size.z; sz++)
			for (IntType sy = 0; sy < section->builder.size.y; sy++)
			for (IntType sx = 0; sx < section->builder.size.x; sx++, b++)
			{
				// Get block position
				IntType bx = section->builder.pos.x + sx;
				IntType by = section->builder.pos.y + sy;
				IntType bz = section->builder.pos.z + sz;
				IntType bufferPos = bz * (IntType)self->build_size_xy + by * Builder::size.x + bx;

				obj_block* block = nullptr;
				BuilderState state;

				// Get block from legacy id+data
				IntType off = blockData + bufferPos * 2;
				uint8_t legacyId = CAST_BITS(uint8_t, buffer->data[off]);
				uint8_t legacyData = CAST_BITS(uint8_t, buffer->data[off + 1]) & 15;
				if (legacyId > 0)
				{
					block = ObjTypeOpt(obj_block, global::legacy_block_obj[legacyId][legacyData]);
					state.stateId = global::legacy_block_state_id[legacyId][legacyData].ToInt();
				}

				if (block)
				{
					state.blockId = block->block_id;
					if (block->timeline)
						numTimelines++;
				}

				section->builder.paletteIndices[b] = section->AddBuilderState(state);
			}

			section->builder.palette.Trim();
		}

		self->sch_timeline_amount = numTimelines;
		debug_timer_stop("Loaded .blocks");
	}

	void builder_done(Scope<obj_builder> self)
	{
		for (IntType s = 0; s < Builder::sections.Size(); s++)
			delete Builder::sections[s];
		
		Builder::sections.FreeData();
		Builder::offset = { 0, 0, 0 };

		self->build_multithreaded = null_;
		self->block_meshes = ArrType();
		self->build_transform = false;
	}

	void builder_set_block(ScopeAny self, IntType x, IntType y, IntType z, IntType blockId, IntType stateId, BoolType waterlogged)
	{
		WorldVec pos = { x, y, z };
		Section* section = Builder::GetSection(pos);
		BuilderState state = { (uint16_t)blockId, (uint16_t)stateId, waterlogged };

		// Sparse structures leave unlisted positions as air
		if (!section->builder.palette.Size())
			section->AddBuilderState({ 0, 0, false });

		section->builder.paletteIndices[section->GetBlockOffset(pos)] = section->AddBuilderState(state);
	}

	void builder_set_state_id(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z, IntType val)
	{
		WorldVec pos = { x, y, z };
		Builder::GetSection(pos)->GetBuilderState(pos).stateId = val;
	}

	void builder_set_render_model(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z, IntType val)
	{
		WorldVec pos = { x, y, z };
		Builder::GetSection(pos)->GetRenderModel(pos) = val;
	}

	IntType builder_add_render_model_multi_part(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z, ArrType arr)
	{
		WorldVec worldPos = { x, y, z };
		Section* section = Builder::GetSection(worldPos);
		IntType size = section->builder.renderModelMultipartIds.Size();

		IntType index;
		for (index = size - 1; index >= 1; index--)
			if (section->builder.renderModelMultipartIds.Value(index) == arr)
				break;
		
		if (index == 0)
		{
			index = size;
			section->builder.renderModelMultipartIds.Append(arr);
		}

		section->GetRenderModel(worldPos) = -index; // Negative number to use multipart list
		
		return 0;
	}

	IntType builder_get_block(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z)
	{
		WorldVec worldPos = { x, y, z };
		obj_block* block = Builder::blocks[Builder::GetSection(worldPos)->GetBuilderState(worldPos).blockId];
		return (block ? block->id : null_);
	}

	IntType builder_get_state_id(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z)
	{
		WorldVec worldPos = { x, y, z };
		return Builder::GetSection(worldPos)->GetBuilderState(worldPos).stateId;
	}

	IntType builder_get_waterlogged(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z)
	{
		WorldVec worldPos = { x, y, z };
		return Builder::GetSection(worldPos)->GetBuilderState(worldPos).waterlogged;
	}

	IntType builder_get_render_model_index(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z)
	{
		WorldVec worldPos = { x, y, z };
		return Builder::GetSection(worldPos)->GetRenderModel(worldPos);
	}

	IntType builder_get_render_model(Scope<obj_builder_thread> self, IntType x, IntType y, IntType z)
	{
		IntType index = builder_get_render_model_index(self, x, y, z);
		if (index <= 0 || index >= Builder::renderModels.Size() || !Builder::renderModels[index])
			return null_;

		return Builder::renderModels[index]->id;
	}

	ArrType builder_get_render_model_multipart(IntType x, IntType y, IntType z, IntType index)
	{
		return Builder::GetSection({ x, y, z })->builder.renderModelMultipartIds.Value(index);
	}

	IntType builder_irandom(ScopeAny self, IntType maximum, IntType salt, BoolType useZ)
	{
		// Match the GML coordinate hash using exact integer arithmetic
		constexpr IntType modulus = 2147483647;
		const ArrType& position = sArr(build_pos);
		IntType seed = 17;
		
		for (IntType axis = X_; axis <= (useZ ? Z_ : Y_); axis++)
			seed = (seed * 16807 + position.IntValue(axis) % modulus) % modulus;
		
		seed = (seed + salt % modulus) % modulus;
		if (seed < 0)
			seed += modulus;
		
		for (int i = 0; i < 3; i++)
			seed = ((seed ^ (seed >> 13)) * 48271 + 1) % modulus;
		
		return seed % ((uint64_t)std::max<IntType>(0, maximum) + 1);
	}

	IntType block_get_render_model(ScopeAny self, VarType object, RealType emissive, BoolType offset, BoolType offsetXY)
	{
		const ArrType& models = idVar(object, model).Arr();
		obj_block_render_model* model = nullptr;
		BoolType randBlocks = idVar(global::mc_builder, build_randomize);

		if (models.Size() > 1 && randBlocks)
		{
			// Pick a random model from the list
			IntType totalWeight = idVar(object, total_weight).ToInt();
			IntType rand = builder_irandom(self, totalWeight - 1, 0, true) + 1;
			for (IntType m = 0; m < models.Size(); m++)
			{
				model = ObjType(obj_block_render_model, models.Value(m));
				rand -= model->weight;
				if (rand <= 0)
					break;
			}
		}
		else if (models.Size() > 0 || randBlocks) // Pick first
			model = ObjType(obj_block_render_model, models.Value(0));

		if (model)
		{
			model->emissive = emissive;
			model->random_offset = offset;
			model->random_offset_xy = offsetXY;
			return model->rendermodel_id;
		}

		return 0;
	}

	void builder_set_neighbor_face(Scope<obj_builder_thread> self, IntType modelId, IntType face, IntType opposite)
	{
		// Resolve the neighbor once for all four culling fields
		obj_block_render_model* model = ObjType(obj_block_render_model, modelId);
		BoolType full = model->face_full.BoolValue(opposite);
		IntType depth = model->face_min_depth.IntValue(opposite);
		self->block_face_full[face] = full;
		self->block_face_min_depth[face] = depth;

		// Bounds are only read when a partial face can cull geometry
		if (!full && depth != null_)
		{
			self->block_face_min[face] = model->face_min.vec.Value(opposite);
			self->block_face_max[face] = model->face_max.vec.Value(opposite);
		}
	}

	static RealType BuilderComponent(const VarType& value, IntType axis)
	{
		// Read vectors and arrays without constructing a scalar variant
		if (value.IsVec())
		{
			const VecType& vec = value.Vec();
			if (axis < 0 || axis >= vec.size)
				return 0;

			switch (axis)
			{
				case X_: return vec.x;
				case Y_: return vec.y;
				case Z_: return vec.z;
				default: return vec.w;
			}
		}
		
		if (value.IsArray())
			return value.Arr().RealValue(axis);
		
		return value.Value(axis).ToReal();
	}

	void block_render_model_generate(Scope<obj_builder_thread> self, IntType modelId)
	{
		// Resolve objects once and keep element bounds in numeric locals
		obj_block_render_model* model = ObjType(obj_block_render_model, modelId);
		
		RealType offset[3];
		for (IntType a = X_; a <= Z_; a++)
			offset[a] = self->block_pos.RealValue(a) + model->offset.RealValue(a);
		
		if (self->block_vertex_emissive == null_)
			self->block_vertex_emissive = model->emissive;
		
		VarType minEmissive = self->block_vertex_emissive;
		BoolType leaves = (self->block_current != null_ && idVar(self->block_current, type).Str() == "leaves");

		// Corner bits select from/to on X, Y and Z in the GML face winding order
		static constexpr int corners[6][4] = {
			{ 7, 5, 1, 3 }, { 4, 6, 2, 0 }, { 6, 7, 3, 2 },
			{ 5, 4, 0, 1 }, { 4, 5, 7, 6 }, { 2, 3, 1, 0 }
		};

		for (IntType e = 0; e < model->element_amount; e++)
		{
			obj_block_render_element* element = ObjType(obj_block_render_element, model->element.IntValue(e));
			RealType bounds[2][3];
			for (IntType a = X_; a <= Z_; a++)
			{
				bounds[0][a] = BuilderComponent(element->from, a);
				bounds[1][a] = BuilderComponent(element->to, a);

				if (!element->rotated)
				{
					bounds[0][a] += offset[a];
					bounds[1][a] += offset[a];
				}
			}

			VarType transform = null_;
			if (element->rotated)
				transform = matrix_multiply(element->matrix, matrix_build(offset[X_], offset[Y_], offset[Z_], 0, 0, 0, 1, 1, 1));
			
			self->block_vertex_emissive = std::max(minEmissive.ToReal(), element->light_emission.ToReal() / 15.0);
			
			for (IntType f = 0; f < block_faces; f++)
			{
				if (!element->face_render.BoolValue(f))
					continue;

				IntType depth = self->block_face_min_depth.IntValue(f);
				if (element->face_edge.BoolValue(f) && depth != null_ && depth <= model->face_min_depth.IntValue(f) &&
					!(leaves && depth > e_block_depth_DEPTH0))
				{
					IntType axis = Y_;
					if (f < ZP)
						axis = Z_;
					
					if (self->block_face_full.BoolValue(f) ||
						(self->block_face_min.RealValue(f) <= BuilderComponent(element->from, axis) &&
						 self->block_face_max.RealValue(f) >= BuilderComponent(element->to, axis)))
						continue;
				}

				self->block_vertex_color_index = self->block_color_index;

				IntType vbuf = element->face_vbuffer.IntValue(f);
				if (vbuf == null_)
				{
					IntType index = element->face_depth.IntValue(f) * e_block_vbuffer_amount + element->face_block_vbuffer.IntValue(f);
					obj_block_mesh* blockMesh = ObjType(obj_block_mesh, self->block_mesh);
					vbuf = blockMesh->block_vbuffer.IntValue(index);

					if (!self->block_vertex_color_index)
						self->block_vertex_color_index = element->face_color_index.IntValue(f);
				}
				
				self->block_vbuffer_current = vbuf;

				// Read UVs by reference rather than copying nested arrays
				const ArrType& face = element->face_uv.vec.Value(f).Arr();
				RealType positions[4][3], uv[4][2];
				for (int v = 0; v < 4; v++)
				{
					for (int a = 0; a < 3; a++)
						positions[v][a] = bounds[(corners[f][v] >> a) & 1][a];
					
					const VarType& texcoord = face.vec.Value(v);
					uv[v][0] = BuilderComponent(texcoord, X_);
					uv[v][1] = BuilderComponent(texcoord, Y_);
				}
				
				builder_add_face_real(self,
					positions[0][0], positions[0][1], positions[0][2],
					positions[1][0], positions[1][1], positions[1][2],
					positions[2][0], positions[2][1], positions[2][2],
					positions[3][0], positions[3][1], positions[3][2],
					uv[0][0], uv[0][1], uv[1][0], uv[1][1], uv[2][0], uv[2][1], uv[3][0], uv[3][1], transform
				);
			}

			self->block_vertex_color_index = 0;
			self->block_vertex_emissive = minEmissive;
		}
	}

	static uint32_t BuilderPackNormal(Scope<obj_builder_thread> self, RealType nx, RealType ny, RealType nz)
	{
		// Apply the timeline axes before normalizing
		if (self->build_transform)
			return Vertex::PackNormal(ny, -nx, nz);
		
		return Vertex::PackNormal(nx, ny, nz);
	}

	static Vertex BuilderCreateVertex(Scope<obj_builder_thread> self, RealType x, RealType y, RealType z, RealType tx, RealType ty, uint32_t normal)
	{
		BoolType wavexy, wavez;
		wavexy = false;
		wavez = false;

		// Wave setting
		if (self->block_vertex_wave != e_vertex_wave_NONE)
		{
			// Vertex Z must be within zmin and zmax (if set)
			if ((self->block_vertex_wave_zmin == null_ || z > self->block_vertex_wave_zmin) &&
				(self->block_vertex_wave_zmax == null_ || z < self->block_vertex_wave_zmax))
			{
				if (self->block_vertex_wave == e_vertex_wave_ALL)
				{
					wavexy = true;
					wavez = true;
				}
				else if (self->block_vertex_wave == e_vertex_wave_Z_ONLY)
					wavez = true;
			}
		}

		// Bake the timeline block axes after model transforms
		if (self->build_transform)
		{
			RealType oldX = x;
			x = y;
			y = self->build_size.RealValue(X_) * block_size_ - oldX;
		}

		return Vertex{
			x, y, z, tx, ty,
			normal, (uint8_t)self->block_vertex_color_index.ToInt(),
			wavexy, wavez, self->block_vertex_subsurface, self->block_vertex_emissive
		};
	}

	void builder_add_face(Scope<obj_builder_thread> self,
		VecType pos1, VecType pos2, VecType pos3, VecType pos4,
		VecType tex1, VecType tex2, VecType tex3, VecType tex4, VarType transform)
	{
		builder_add_face_real(self,
			pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z,
			pos3.x, pos3.y, pos3.z, pos4.x, pos4.y, pos4.z,
			tex1.x, tex1.y, tex2.x, tex2.y, tex3.x, tex3.y, tex4.x, tex4.y, transform);
	}

	void builder_add_triangle(Scope<obj_builder_thread> self,
		VecType pos1, VecType pos2, VecType pos3,
		VecType tex1, VecType tex2, VecType tex3, VarType transform)
	{
		builder_add_triangle_real(self,
			pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, pos3.x, pos3.y, pos3.z,
			tex1.x, tex1.y, tex2.x, tex2.y, tex3.x, tex3.y, transform);
	}

	void builder_add_face_real(Scope<obj_builder_thread> self,
		RealType x1, RealType y1, RealType z1,
		RealType x2, RealType y2, RealType z2,
		RealType x3, RealType y3, RealType z3,
		RealType x4, RealType y4, RealType z4,
		RealType tx1, RealType ty1,
		RealType tx2, RealType ty2,
		RealType tx3, RealType ty3,
		RealType tx4, RealType ty4,
		VarType transform)
	{
		// Apply matrix
		if (transform.IsMatrix())
		{
			const Matrix& mat = transform.Mat().matrix;
			VecType p1 = mat * VecType(x1, y1, z1, 1);
			VecType p2 = mat * VecType(x2, y2, z2, 1);
			VecType p3 = mat * VecType(x3, y3, z3, 1);
			VecType p4 = mat * VecType(x4, y4, z4, 1);
			x1 = p1.x, y1 = p1.y, z1 = p1.z;
			x2 = p2.x, y2 = p2.y, z2 = p2.z;
			x3 = p3.x, y3 = p3.y, z3 = p3.z;
			x4 = p4.x, y4 = p4.y, z4 = p4.z;
		}

		// Calculate normal
		RealType nx = (z1 - z2) * (y3 - y2) - (y1 - y2) * (z3 - z2);
		RealType ny = (x1 - x2) * (z3 - z2) - (z1 - z2) * (x3 - x2);
		RealType nz = (y1 - y2) * (x3 - x2) - (x1 - x2) * (y3 - y2);
		uint32_t normal = BuilderPackNormal(self, nx, ny, nz);

		// Add face
		FindVertexBuffer(self->block_vbuffer_current)->AddFace(
			BuilderCreateVertex(self, x1, y1, z1, tx1, ty1, normal),
			BuilderCreateVertex(self, x2, y2, z2, tx2, ty2, normal),
			BuilderCreateVertex(self, x3, y3, z3, tx3, ty3, normal),
			BuilderCreateVertex(self, x4, y4, z4, tx4, ty4, normal),
			self->threadid
		);
	}

	void builder_add_triangle_real(Scope<obj_builder_thread> self,
		RealType x1, RealType y1, RealType z1,
		RealType x2, RealType y2, RealType z2,
		RealType x3, RealType y3, RealType z3,
		RealType tx1, RealType ty1,
		RealType tx2, RealType ty2,
		RealType tx3, RealType ty3,
		VarType transform)
	{
		// Apply matrix
		if (transform.IsMatrix())
		{
			const Matrix& mat = transform.Mat().matrix;
			VecType p1 = mat * VecType(x1, y1, z1, 1);
			VecType p2 = mat * VecType(x2, y2, z2, 1);
			VecType p3 = mat * VecType(x3, y3, z3, 1);
			x1 = p1.x, y1 = p1.y, z1 = p1.z;
			x2 = p2.x, y2 = p2.y, z2 = p2.z;
			x3 = p3.x, y3 = p3.y, z3 = p3.z;
		}

		// Calculate normal
		RealType nx = (z1 - z2) * (y3 - y2) - (y1 - y2) * (z3 - z2);
		RealType ny = (x1 - x2) * (z3 - z2) - (z1 - z2) * (x3 - x2);
		RealType nz = (y1 - y2) * (x3 - x2) - (x1 - x2) * (y3 - y2);
		uint32_t normal = BuilderPackNormal(self, nx, ny, nz);

		// Add triangle
		FindVertexBuffer(self->block_vbuffer_current)->AddTriangle(
			BuilderCreateVertex(self, x1, y1, z1, tx1, ty1, normal),
			BuilderCreateVertex(self, x2, y2, z2, tx2, ty2, normal),
			BuilderCreateVertex(self, x3, y3, z3, tx3, ty3, normal),
			self->threadid
		);
	}

	BoolType res_load_scenery_world(Scope<obj_resource> self)
	{
		BoolType snapshot = self->scenery_snapshot_save;
		self->scenery_snapshot_save = true;

		// Sections already generated
		if (Builder::sections.Size())
			return true;

		// Missing world
		if (!QDir(self->world_regions_dir.Str()).exists())
			return false;

		World::Open((QString)self->world_regions_dir.Str());

		// Missing regions in dimension
		if (!World::regions.count())
		{
			World::Close();
			return false;
		}

		// Get box
		VecType boxStart = self->world_box_start;
		VecType boxEnd = self->world_box_end;
		if (boxEnd.x <= boxStart.x || boxEnd.y <= boxStart.y || boxEnd.z <= boxStart.z)
		{
			World::Close();
			return false;
		}

		WorldBox box(WorldVec(boxStart.x, boxStart.y, boxStart.z), WorldVec(boxEnd.x, boxEnd.y, boxEnd.z));

		// Find level.dat above the dimension's region directory
		QDir worldDir(self->world_regions_dir.Str());
		while (!worldDir.exists("level.dat") && worldDir.cdUp()) {}

		// Extract DataVersion and create schematic exporter
		std::unique_ptr<SchematicExport> schematic;
		if (snapshot)
		{
			try
			{
				if (!World::AddSave(worldDir.path()))
					throw QString("Could not determine the world format");

				IntType dataVersion = World::saves.value(worldDir.path()).dataVersion;
				schematic.reset(new SchematicExport(box, dataVersion, true, false));
			}
			catch (const QString& error)
			{
				WARNING("Could not create schematic snapshot: " + error);
			}
		}

		World::GenerateBuilderSections(box, schematic.get());

		// Apply filter
		res_load_scenery_filter_mask(self);
		res_load_scenery_block_map(self);

		World::ProcessBuilderEntities();

		if (schematic)
		{
			if (schematic->error.isEmpty())
			{
				// Read only entity data
				NbtCompound entityRoot;
				entityRoot.value["Entities"] = schematic->schematic->value.value("Entities");
				
				Map* entityMap = entityRoot.ToMap();
				entityRoot.value.remove("Entities");
				
				script_execute(Scope<obj_builder>(ObjType(obj_builder, global::mc_builder)), {
					asset_get_index("builder_read_entities"), entityMap->Value("Entities")
				});

				delete entityMap;
			}

			schematic->SaveResource(self.object);
		}

		World::Close();

		return true;
	}

	void res_save_block_cache(Scope<obj_resource> self, StringType filename)
	{
	#if !BLOCK_MESH_CACHE_ENABLED
		return;
	#endif

		obj_resource* res = self.object;
		if (!res->block_meshes.Size())
			return;

		QByteArray assetsVersion = VarGetStr(global::_app->setting_minecraft_assets_version).QStr().toUtf8();
		qint64 totalBytes = sizeof(uchar) + sizeof(quint16) + assetsVersion.size() + sizeof(qint64) * 3 + sizeof(qint32) * 3;
		RealType approxGzipRatio = 0.14;

		for (IntType s = 0; s < res->block_meshes.Size(); s++)
		{
			totalBytes += sizeof(quint8);

			obj_block_mesh* blockMesh = ObjTypeOpt(obj_block_mesh, res->block_meshes.Value(s));
			if (!blockMesh)
				continue;

			totalBytes += sizeof(quint64);

			for (IntType i = 0; i < e_block_depth_amount * e_block_vbuffer_amount; i++)
			{
				if (!blockMesh->block_vbuffer_active.BoolValue(i))
					continue;

				VertexBuffer* vbuf = FindVertexBuffer(blockMesh->block_vbuffer.IntValue(i));
				if (!vbuf)
					return;

				totalBytes += vbuf->GetWriteBytes();
			}
		}

		auto freeCpuData = [&]
		{
			for (IntType s = 0; s < res->block_meshes.Size(); s++)
			{
				obj_block_mesh* blockMesh = ObjTypeOpt(obj_block_mesh, res->block_meshes.Value(s));
				if (!blockMesh)
					continue;

				for (IntType i = 0; i < e_block_depth_amount * e_block_vbuffer_amount; i++)
				{
					VertexBuffer* vbuf = FindVertexBuffer(blockMesh->block_vbuffer.IntValue(i));
					if (!vbuf)
						continue;

					// Small buffers still need CPU data for batching, even without a cache
					if (vbuf->batching && vbuf->numIndices <= MAX_BATCH_INDICES)
						continue;

					for (Mesh<>* mesh : vbuf->meshes)
					{
						mesh->vertexData.FreeData();
						mesh->indexData.FreeData();
					}
				}
			}
		};

		if (totalBytes > std::numeric_limits<int>::max())
		{
			WARNING("Block mesh cache exceeds the byte array size limit");
			freeCpuData();
			return;
		}

		IntType mb = ceil((totalBytes / 1000000.0) * approxGzipRatio);
		if (mb > 50)
		{
			if (res->scenery_cache_save == null_)
				res->scenery_cache_save = question(text_get({ "load_scenery/save_cache", string(mb) + StringType("MB") }));

			if (!res->scenery_cache_save)
			{
				// Release CPU data that is only retained for cache generation
				freeCpuData();
				return;
			}
		}

		Timer tmr;
		QByteArray data;
		data.reserve((int)totalBytes);

		QDataStream out(&data, QIODevice::WriteOnly);

		// Save format
		uchar format = BLOCK_MESH_CACHE_FORMAT;
		out << format;

		// Save Minecraft assets version
		out << (quint16)assetsVersion.size();
		out.writeRawData(assetsVersion.constData(), assetsVersion.size());

		// Save size
		out << (qint64)res->scenery_size[X_];
		out << (qint64)res->scenery_size[Y_];
		out << (qint64)res->scenery_size[Z_];
		out << (qint32)res->block_meshes_size.Value(X_);
		out << (qint32)res->block_meshes_size.Value(Y_);
		out << (qint32)res->block_meshes_size.Value(Z_);

		// Write meshes and active buffers in XYZ order
		for (IntType s = 0; s < res->block_meshes.Size(); s++)
		{
			obj_block_mesh* blockMesh = ObjTypeOpt(obj_block_mesh, res->block_meshes.Value(s));
			out << quint8(blockMesh != nullptr);
			if (!blockMesh)
				continue;

			quint64 mask = 0;
			for (IntType i = 0; i < e_block_depth_amount * e_block_vbuffer_amount; i++)
				if (blockMesh->block_vbuffer_active.BoolValue(i))
					mask |= quint64(1) << i;

			out << mask;
			for (IntType i = 0; i < e_block_depth_amount * e_block_vbuffer_amount; i++)
				if (mask & (quint64(1) << i))
					FindVertexBuffer(blockMesh->block_vbuffer.IntValue(i))->Write(out);
		}

		tmr.Print("Serialize block mesh cache (" + filename.QStr() + ")");

		if (out.status() != QDataStream::Ok || data.size() != totalBytes)
		{
			WARNING("Could not serialize block mesh cache");
			return;
		}

		Gzip::WriteAsync(std::move(data), filename.QStr(), "Block mesh cache", 8);
	}

	static BoolType LoadLegacyBlockCache(Scope<obj_resource> self, QDataStream& in);

	BoolType res_load_block_cache(Scope<obj_resource> self, StringType filename)
	{
	#if !BLOCK_MESH_CACHE_ENABLED
		return false;
	#endif

		Timer tmr;
		tmr.Print("Unzip block mesh cache");

		QByteArray data;
		BoolType decompressed = Gzip::Decompress(filename, data);
		if (!decompressed)
			return false;

		tmr.Reset();

		QDataStream in(&data, QIODevice::ReadOnly);

		uchar format = 0;
		in >> format;
		if (in.status() != QDataStream::Ok)
			return false;

		// Legacy file
		if (format == BLOCK_MESH_CACHE_FORMAT_LEGACY)
		{
			BoolType loaded = LoadLegacyBlockCache(self, in);
			if (loaded)
				tmr.Print("Load legacy block mesh cache");

			return loaded;
		}

		if (in.status() != QDataStream::Ok || format != BLOCK_MESH_CACHE_FORMAT)
			return false;

		quint16 assetsVersionSize = 0;
		in >> assetsVersionSize;
		if (in.status() != QDataStream::Ok || !assetsVersionSize || assetsVersionSize > 64)
			return false;

		QByteArray assetsVersion(assetsVersionSize, '\0');
		if (in.readRawData(assetsVersion.data(), assetsVersionSize) != assetsVersionSize
			|| assetsVersion != VarGetStr(global::_app->setting_minecraft_assets_version).QStr().toUtf8())
			return false;

		// Load size
		qint64 sizeX = 0, sizeY = 0, sizeZ = 0;
		qint32 dimX = 0, dimY = 0, dimZ = 0;
		in >> sizeX;
		in >> sizeY;
		in >> sizeZ;
		in >> dimX;
		in >> dimY;
		in >> dimZ;
		if (in.status() != QDataStream::Ok || sizeX <= 0 || sizeY <= 0 || sizeZ <= 0 ||
			sizeX > std::numeric_limits<qint32>::max() || sizeY > std::numeric_limits<qint32>::max() ||
			sizeZ > std::numeric_limits<qint32>::max() ||
			dimX != (sizeY + block_mesh_size - 1) / block_mesh_size ||
			dimY != (sizeX + block_mesh_size - 1) / block_mesh_size ||
			dimZ != (sizeZ + block_mesh_size - 1) / block_mesh_size)
			return false;

		qint64 meshCount = qint64(dimX) * dimY * dimZ;
		if (meshCount > in.device()->bytesAvailable() || meshCount > std::numeric_limits<int>::max())
			return false;

		const IntType vbufCount = e_block_depth_amount * e_block_vbuffer_amount;
		QVector<QVector<VertexBuffer*>> meshVbuffers((int)meshCount);
		BoolType valid = true;

		for (IntType s = 0; s < meshCount && valid; s++)
		{
			quint8 present = 0;
			in >> present;
			if (in.status() != QDataStream::Ok || present > 1)
			{
				valid = false;
				break;
			}

			if (!present)
				continue;

			quint64 mask = 0;
			in >> mask;
			if (in.status() != QDataStream::Ok || !mask || (mask >> vbufCount))
			{
				valid = false;
				break;
			}

			meshVbuffers[s].resize(vbufCount);
			for (IntType i = 0; i < vbufCount; i++)
			{
				if (!(mask & (quint64(1) << i)))
					continue;

				VertexBuffer* vbuf = new VertexBuffer(in, false);
				meshVbuffers[s][i] = vbuf;
				if (!vbuf->valid || !vbuf->numIndices)
				{
					valid = false;
					break;
				}
			}
		}

		if (!valid || !in.atEnd())
		{
			for (const auto& vbuffers : meshVbuffers)
				for (VertexBuffer* vbuf : vbuffers)
					delete vbuf;
			
			return false;
		}

		block_meshes_destroy(self);

		ArrType meshes;
		BoolType transparent = false;

		for (IntType s = 0; s < meshCount; s++)
		{
			meshes[s] = null_;
			if (meshVbuffers[s].isEmpty())
				continue;

			obj_block_mesh* blockMesh = new obj_block_mesh;
			ArrType buffers, active, depths;
			for (IntType d = 0; d < e_block_depth_amount; d++)
				depths[d] = false;

			for (IntType i = 0; i < vbufCount; i++)
			{
				if (i % e_block_vbuffer_amount == 0)
					blockMesh->block_vbuffer_render_offsets[i / e_block_vbuffer_amount] = blockMesh->block_vbuffer_render_order.Size();

				VertexBuffer* vbuf = meshVbuffers[s][i];
				buffers[i] = (vbuf ? vbuf->id : null_);
				active[i] = (vbuf != nullptr);
				if (vbuf)
				{
					IntType depth = i / e_block_vbuffer_amount;
					depths[depth] = true;
					if (depth != e_block_depth_DEPTH0)
						transparent = true;

					blockMesh->block_vbuffer_render_order.Append(i);
				}
			}

			blockMesh->block_vbuffer = buffers;
			blockMesh->block_vbuffer_active = active;
			blockMesh->block_vbuffer_depth_active = depths;
			blockMesh->block_vbuffer_render_offsets[e_block_depth_amount] = blockMesh->block_vbuffer_render_order.Size();

			meshes[s] = blockMesh->id;
		}

		self->scenery_size = { (RealType)sizeX, (RealType)sizeY, (RealType)sizeZ };
		self->block_meshes_size = { (RealType)dimX, (RealType)dimY, (RealType)dimZ };
		self->block_meshes = meshes;
		self->block_meshes_transparent = transparent;

		tmr.Print("Read block mesh cache");
		
		return true;
	}

	// Load 2.0 legacy .meshcache file.
	static BoolType LoadLegacyBlockCache(Scope<obj_resource> self, QDataStream& in)
	{
		qint64 sizeX = 0, sizeY = 0, sizeZ = 0;
		in >> sizeX;
		in >> sizeY;
		in >> sizeZ;
		if (in.status() != QDataStream::Ok || sizeX <= 0 || sizeY <= 0 || sizeZ <= 0 ||
			sizeX > std::numeric_limits<qint32>::max() || sizeY > std::numeric_limits<qint32>::max() ||
			sizeZ > std::numeric_limits<qint32>::max())
			return false;

		const qint32 dimX = (sizeY + block_mesh_size - 1) / block_mesh_size;
		const qint32 dimY = (sizeX + block_mesh_size - 1) / block_mesh_size;
		const qint32 dimZ = (sizeZ + block_mesh_size - 1) / block_mesh_size;
		const qint64 meshCount = qint64(dimX) * dimY * dimZ;
		if (meshCount > std::numeric_limits<int>::max())
			return false;

		VarType sheetSize = global::minecraft_block_sheet_size.Value(e_block_sheet_STATIC16);
		const RealType staticUvScaleX = BLOCK_MESH_CACHE_LEGACY_SHEET_SIZE / sheetSize.Value(X_).ToReal();
		const RealType staticUvScaleY = BLOCK_MESH_CACHE_LEGACY_SHEET_SIZE / sheetSize.Value(Y_).ToReal();
		const RealType legacyBlockWidth = (RealType)sizeY * block_size_;
		const IntType vbufCount = e_block_depth_amount * e_block_vbuffer_amount;
		QVector<QVector<VertexBuffer*>> meshVbuffers((int)meshCount);

		// Format 2 stores RGBA before the UV coordinates
		struct LegacyVertex
		{
			float x, y, z;
			uint32_t normal, color;
			float u, v;
			uint32_t data, tangent;
		};
		static_assert(sizeof(LegacyVertex) == 36, "Unexpected legacy vertex layout");

		QHash<uint32_t, uint8_t> colorIndices;
		const ArrType& colors = ObjType(obj_resource, global::mc_res)->block_colors;
		for (IntType i = e_biome_color_amount; i < colors.Size() / 4; i++)
		{
			// Biome colors use the legacy buffer type, cloud colors are not block tints
			if (i >= e_color_palette_CLOUDS_TOP && i < e_color_palette_amount)
				continue;

			IntType offset = i * 4;
			IntType color = make_color_rgb(
				std::round(colors.RealValue(offset) * 255),
				std::round(colors.RealValue(offset + 1) * 255),
				std::round(colors.RealValue(offset + 2) * 255)
			);
			colorIndices[color] = i + 1;
		}

		struct LegacyBuffer
		{
			e_block_vbuffer buffer;
			uint8_t colorIndex;
		};
		static const QVector<LegacyBuffer> legacyBuffers = {
			{ e_block_vbuffer_STATIC16, 0 },
			{ e_block_vbuffer_ANIMATED, 0 },
			{ e_block_vbuffer_STATIC16, e_biome_color_GRASS + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_FOLIAGE + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_OAK + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_SPRUCE + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_BIRCH + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_JUNGLE + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_ACACIA + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_DARK_OAK + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_MANGROVE + 1 },
			{ e_block_vbuffer_WATER, 0 }
		};
		constexpr RealType meshStride = block_mesh_size * block_size_;

		auto rotateDirection = [](uint32_t packed)
		{
			return ((packed >> 8) & 255u) |
					((255u - (packed & 255u)) << 8) |
					(packed & 0xFFFF0000u);
		};

		BoolType valid = true;
		for (IntType d = 0; d < e_block_depth_amount && valid; d++)
		for (IntType vb = 0; vb < legacyBuffers.size() && valid; vb++)
		{
			qint64 numMeshes = 0;
			in >> numMeshes;
			if (in.status() != QDataStream::Ok || numMeshes < 0 ||
				numMeshes > in.device()->bytesAvailable() / (sizeof(qint64) * 2))
			{
				valid = false;
				break;
			}

			const IntType target = d * e_block_vbuffer_amount + legacyBuffers[vb].buffer;
			const BoolType staticSheet = legacyBuffers[vb].buffer == e_block_vbuffer_STATIC16;
			for (qint64 m = 0; m < numMeshes && valid; m++)
			{
				qint64 numVert = 0, numInd = 0;
				in >> numVert;
				in >> numInd;
				if (in.status() != QDataStream::Ok || numVert <= 0 || numInd <= 0 ||
					numVert > MAX_MESH_INDICES || numInd > MAX_MESH_INDICES || numInd % 3 != 0)
				{
					valid = false;
					break;
				}

				const qint64 vertexBytes = numVert * sizeof(LegacyVertex);
				const qint64 indexBytes = numInd * sizeof(uint32_t);
				if (vertexBytes > std::numeric_limits<int>::max() || indexBytes > std::numeric_limits<int>::max() ||
					vertexBytes + indexBytes > in.device()->bytesAvailable())
				{
					valid = false;
					break;
				}

				QVector<LegacyVertex> legacyVertices((int)numVert);
				QVector<Vertex> vertices((int)numVert);
				QVector<uint32_t> indices((int)numInd);
				if (in.readRawData((char*)legacyVertices.data(), (int)vertexBytes) != vertexBytes ||
					in.readRawData((char*)indices.data(), (int)indexBytes) != indexBytes)
				{
					valid = false;
					break;
				}

				for (IntType v = 0; v < numVert; v++)
				{
					const LegacyVertex& old = legacyVertices[v];
					Vertex& vertex = vertices[v];
					vertex.x = old.x;
					vertex.y = old.y;
					vertex.z = old.z;
					vertex.u = old.u;
					vertex.v = old.v;
					vertex.data1 = old.normal;
					vertex.data2 = old.data;
					vertex.tangent = old.tangent;

					if (!std::isfinite(vertex.x) || !std::isfinite(vertex.y) || !std::isfinite(vertex.z))
					{
						valid = false;
						break;
					}

					float oldX = vertex.x;
					vertex.x = vertex.y;
					vertex.y = legacyBlockWidth - oldX;
					vertex.data1 = rotateDirection(vertex.data1);

					uint8_t colorIndex = legacyBuffers[vb].colorIndex;
					uint32_t color = old.color & 0x00FFFFFFu;
					if (color != 0x00FFFFFFu)
						colorIndex = colorIndices.value(color, colorIndex);

					vertex.SetColorIndex(colorIndex);
					vertex.tangent = rotateDirection(vertex.tangent);

					if (staticSheet)
					{
						vertex.u *= staticUvScaleX;
						vertex.v *= staticUvScaleY;
					}
				}

				if (!valid)
					break;

				for (IntType i = 0; i < numInd && valid;)
				{
					BoolType quad = i + 5 < numInd && indices[i] == indices[i + 5] &&
						indices[i + 2] == indices[i + 3];

					const IntType count = quad ? 4 : 3;
					uint32_t corners[4] = { indices[i], indices[i + 1], indices[i + 2], quad ? indices[i + 4] : 0 };
					for (IntType c = 0; c < count; c++)
						if (corners[c] >= numVert)
							valid = false;

					if (!valid)
						break;

					RealType pos[3] = { 0, 0, 0 };
					for (IntType c = 0; c < count; c++)
					{
						const Vertex& vertex = vertices[corners[c]];
						pos[X_] += vertex.x;
						pos[Y_] += vertex.y;
						pos[Z_] += vertex.z;
					}

					const uint32_t normal = vertices[corners[0]].data1;
					const uint8_t packedNormal[3] = { uint8_t(normal), uint8_t(normal >> 8), uint8_t(normal >> 16) };
					IntType axis = 0;
					for (IntType a = 1; a < 3; a++)
						if (std::abs((IntType)packedNormal[a] - 127) > std::abs((IntType)packedNormal[axis] - 127))
							axis = a;

					// Bias boundary faces toward the block behind their normal
					pos[axis] -= (packedNormal[axis] > 127 ? 0.01 : -0.01) * count;

					// Convert face centers back to builder axes for mesh indexing
					const IntType sx = (IntType)std::clamp(std::floor((legacyBlockWidth - pos[Y_] / count) / meshStride), 0.0, (double)dimX - 1);
					const IntType sy = (IntType)std::clamp(std::floor(pos[X_] / count / meshStride), 0.0, (double)dimY - 1);
					const IntType sz = (IntType)std::clamp(std::floor(pos[Z_] / count / meshStride), 0.0, (double)dimZ - 1);
					const IntType meshIndex = (sz * dimY + sy) * dimX + sx;

					if (meshVbuffers[meshIndex].isEmpty())
						meshVbuffers[meshIndex].resize(vbufCount);

					VertexBuffer*& vbuf = meshVbuffers[meshIndex][target];
					if (!vbuf)
						vbuf = new VertexBuffer;

					if (quad)
						vbuf->AddFace(vertices[corners[0]], vertices[corners[1]], vertices[corners[2]], vertices[corners[3]]);
					else
						vbuf->AddTriangle(vertices[corners[0]], vertices[corners[1]], vertices[corners[2]]);

					i += quad ? 6 : 3;
				}
			}
		}

		if (!valid || !in.atEnd())
		{
			// Free buffers
			for (const auto& buffers : meshVbuffers)
			for (VertexBuffer* vbuf : buffers)
			{
				if (!vbuf)
					continue;

				for (auto& thread : vbuf->threads)
					for (auto* mesh : thread.meshes)
						delete mesh;

				delete vbuf;
			}

			return false;
		}

		ArrType meshes;
		BoolType transparent = false;

		for (IntType s = 0; s < meshCount; s++)
		{
			meshes[s] = null_;
			if (meshVbuffers[s].isEmpty())
				continue;

			obj_block_mesh* blockMesh = new obj_block_mesh;
			ArrType buffers, active, depths;
			for (IntType d = 0; d < e_block_depth_amount; d++)
				depths[d] = false;

			for (IntType i = 0; i < vbufCount; i++)
			{
				if (i % e_block_vbuffer_amount == 0)
					blockMesh->block_vbuffer_render_offsets[i / e_block_vbuffer_amount] = blockMesh->block_vbuffer_render_order.Size();

				VertexBuffer* vbuf = meshVbuffers[s][i];
				if (vbuf)
				{
					vbuf->Complete(false);
					vbuf->batching = false;

					for (Mesh<>* mesh : vbuf->meshes)
					{
						mesh->vertexData.FreeData();
						mesh->indexData.FreeData();
					}
				}

				buffers[i] = (vbuf ? vbuf->id : null_);
				active[i] = (vbuf != nullptr);
				if (vbuf)
				{
					IntType depth = i / e_block_vbuffer_amount;
					depths[depth] = true;
					blockMesh->block_vbuffer_render_order.Append(i);
					if (depth != e_block_depth_DEPTH0)
						transparent = true;
				}
			}

			blockMesh->block_vbuffer = buffers;
			blockMesh->block_vbuffer_active = active;
			blockMesh->block_vbuffer_depth_active = depths;
			blockMesh->block_vbuffer_render_offsets[e_block_depth_amount] = blockMesh->block_vbuffer_render_order.Size();
			meshes[s] = blockMesh->id;
		}

		block_meshes_destroy(self);

		self->scenery_size = { (RealType)sizeX, (RealType)sizeY, (RealType)sizeZ };
		self->block_meshes_size = { (RealType)dimX, (RealType)dimY, (RealType)dimZ };
		self->block_meshes = meshes;
		self->block_meshes_transparent = transparent;

		return true;
	}
}
