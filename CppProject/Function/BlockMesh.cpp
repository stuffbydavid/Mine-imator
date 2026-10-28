#include "Generated/Scripts.hpp"

#include "Asset/Buffer.hpp"
#include "Asset/VertexBuffer.hpp"
#include "World/World.hpp"

namespace CppProject
{
	IntType block_mesh_get_index(IntType xx, IntType yy, IntType zz, IntType meshwidth, IntType meshheight)
	{
		return ((zz / block_mesh_size) * meshheight + yy / block_mesh_size) * meshwidth + xx / block_mesh_size;
	}

	static BuilderState BlockMeshesGetBlock(obj_timeline* self, IntType xx, IntType yy, IntType zz, BoolType source)
	{
		BuilderState state;
		obj_template* temp = ObjTypeOpt(obj_template, self->temp);
		obj_resource* res = temp ? ObjTypeOpt(obj_resource, temp->scenery) : nullptr;
		if (!res || !res->ready)
			return state;

		// Look up added block at position
		BoolType edited = false;
		if (!source)
		{
			for (IntType i = self->blocks_added.Size() - 1; i >= 0; i--)
			{
				const ArrType& entry = self->blocks_added.vec.Value(i).Arr();
				const VecType blockPos = entry.vec.Value(0).ToVec();
				if (blockPos.x != xx || blockPos.y != yy || blockPos.z != zz)
					continue;

				IntType paletteIndex = entry.IntValue(1);
				if (paletteIndex < 0 || paletteIndex >= self->blocks_added_palette.Size())
					return state;

				const ArrType& palette = self->blocks_added_palette.vec.Value(paletteIndex).Arr();
				state.blockId = palette.IntValue(0);
				state.stateId = palette.IntValue(1);
				edited = true;
				if (!state.blockId)
					return state;

				break;
			}
		}

		WorldVec size = res->scenery_size.ToVec();
		WorldVec repeat = temp->block_repeat_enable ? WorldVec(temp->block_repeat.ToVec()) : WorldVec(1, 1, 1);
		if (size.x <= 0 || size.y <= 0 || size.z <= 0 || xx < 0 || yy < 0 || zz < 0 ||
			xx >= size.x * repeat.x || yy >= size.y * repeat.y || zz >= size.z * repeat.z)
			return state;

		// Undo the builder-to-render transform and locate the source mesh
		IntType oldx = xx;
		xx = size.y - 1 - yy % size.y;
		yy = oldx % size.x;
		zz %= size.z;
		
		IntType meshIndex = block_mesh_get_index(xx, yy, zz, res->block_meshes_size.x, res->block_meshes_size.y);
		if (meshIndex < 0 || meshIndex >= res->block_meshes.Size())
			return state;

		obj_block_mesh* mesh = ObjTypeOpt(obj_block_mesh, res->block_meshes.Value(meshIndex));
		if (!mesh || mesh->block_palette_buffer == null_ || mesh->block_grid_buffer == null_)
			return state;

		Buffer* palette = FindBuffer(mesh->block_palette_buffer);
		Buffer* grid = FindBuffer(mesh->block_grid_buffer);
		if (!palette || !grid)
			return state;

		WorldVec gridSize = mesh->block_grid_size;
		xx %= block_mesh_size;
		yy %= block_mesh_size;
		zz %= block_mesh_size;
		if (xx >= gridSize.x || yy >= gridSize.y || zz >= gridSize.z)
			return state;

		IntType count = palette->data.Size() / 4;
		IntType totalSize = gridSize.x * gridSize.y * gridSize.z;
		if (!count || count > totalSize)
			return state;

		int bits = 0;
		while ((quint64(1) << bits) < (quint64)count)
			bits++;

		IntType gridBytes = (totalSize * bits + 7) / 8;
		if (gridBytes + (count + 7) / 8 > grid->data.Size())
			return state;

		// Read only the bytes touched by this packed index
		IntType bitPos = ((zz * gridSize.y + yy) * gridSize.x + xx) * bits;
		int shift = bitPos % 8;
		int bytes = (shift + bits + 7) / 8;
		quint64 packed = 0;
		for (int b = 0; b < bytes; b++)
			packed |= quint64(grid->data[bitPos / 8 + b]) << (b * 8);

		IntType index = (packed >> shift) & ((quint64(1) << bits) - 1);
		if (index >= count)
			return state;

		const uchar* entry = palette->data.Data() + index * 4;
		if (!edited)
		{
			state.blockId = entry[0] | (uint16_t(entry[1]) << 8);
			state.stateId = entry[2] | (uint16_t(entry[3]) << 8);
		}

		// Replacements retain the source position's waterlogging
		IntType byteIndex = gridBytes + index / 8;
		uchar bitMask = 1 << (index % 8);
		state.waterlogged = (grid->data[byteIndex] & bitMask) != 0;
		
		return state;
	}

	ArrType block_meshes_get_block(Scope<obj_timeline> self, IntType xx, IntType yy, IntType zz, BoolType source)
	{
		BuilderState state = BlockMeshesGetBlock(self.object, xx, yy, zz, source);
		return ArrType::From({ (IntType)state.blockId, (IntType)state.stateId, state.waterlogged });
	}

	VarType tl_update_block_meshes(Scope<obj_timeline> self, VarType pos, IntType blockId, IntType stateId)
	{
		obj_template* temp = ObjTypeOpt(obj_template, self->temp);
		obj_resource* res = temp ? ObjTypeOpt(obj_resource, temp->scenery) : nullptr;
		if (self->type != e_tl_type_SCENERY || !res || !res->ready)
			return null_;

		StringType ext = filename_ext(res->filename);
		BoolType legacy = (ext == ".schematic" || ext == ".blocks");

		// A block position is supplied to add/replace a block
		BoolType adding = pos.IsContainer();
		BuilderState editState = { (uint16_t)blockId, (uint16_t)stateId, false };
		WorldVec editBlockPos;
		if (adding)
			editBlockPos = pos.ToVec();

		WorldVec size = {
			res->scenery_size.Value(X_).ToInt(),
			res->scenery_size.Value(Y_).ToInt(),
			res->scenery_size.Value(Z_).ToInt()
		};
		WorldVec repeat = temp->block_repeat_enable ? WorldVec((VecType)temp->block_repeat) : WorldVec(1, 1, 1);
		WorldVec totalSize = size * repeat;
		IntType meshCount = res->block_meshes.Size();
		IntType total = meshCount * repeat.x * repeat.y * repeat.z;
		BoolType rebuild = (!adding || self->block_meshes_edit.Size() != total);

		// Load missing palettes before changing geometry or history
		BoolType needBlocks = !meshCount;
		for (IntType s = 0; s < meshCount; s++)
		{
			obj_block_mesh* mesh = ObjTypeOpt(obj_block_mesh, res->block_meshes.Value(s));
			if (mesh && (mesh->block_palette_buffer == null_ || mesh->block_grid_buffer == null_))
				needBlocks = true;
		}

		if (needBlocks)
		{
			// Read blocks only from file without regenerating meshes
			if (!res_load_scenery_file(Scope<obj_resource>(res), global::_app->project_folder + StringType("/") + res->filename, true))
				return null_;

			meshCount = res->block_meshes.Size();
			total = meshCount * repeat.x * repeat.y * repeat.z;
			rebuild = true;
		}

		if (!meshCount)
			return null_;

		// Get previous block at position for undo
		BuilderState previous;
		if (adding)
		{
			previous = BlockMeshesGetBlock(self.object, editBlockPos.x, editBlockPos.y, editBlockPos.z, false);
			if (blockId)
				editState.waterlogged = BlockMeshesGetBlock(self.object, editBlockPos.x, editBlockPos.y, editBlockPos.z, true).waterlogged;

			// No change
			if (previous.blockId == editState.blockId && previous.stateId == editState.stateId && previous.waterlogged == editState.waterlogged)
				return null_;
		}

		QVector<WorldVec> blocksAdded;
		if (rebuild)
		{
			for (IntType s = 0; s < self->block_meshes_edit.Size(); s++)
				delete ObjTypeOpt(obj_block_mesh, self->block_meshes_edit.Value(s));

			self->block_meshes = array_create({ total, null_ });
			self->block_meshes_edit = array_create({ total, null_ });
			self->block_meshes_active = array_create({ total, false });
			self->block_meshes_size = res->block_meshes_size;
			self->block_meshes_transparent = res->block_meshes_transparent;

			for (IntType s = 0; s < total; s++)
			{
				self->block_meshes[s] = res->block_meshes.Value(s % meshCount);
				self->block_meshes_active[s] = res->block_meshes_active.Value(s % meshCount);
			}

			for (IntType i = 0; i < self->blocks_added.Size(); i++)
				blocksAdded.append((WorldVec)self->blocks_added.Value(i).Arr().Value(0));
		}

		if (adding)
			blocksAdded.append(editBlockPos);

		// Create set of edited blocks and their six neighbors before generating any geometry
		QVector<WorldVec> blockPosList;
		QSet<IntType> blockPosKeys;

		for (const WorldVec& addedPos : blocksAdded)
		for (IntType f = -1; f < block_faces; f++)
		{
			WorldVec blockPos = addedPos;

			// Find neighbor block
			switch (f)
			{
				case XP: blockPos.x++; break;
				case XN: blockPos.x--; break;
				case YP: blockPos.y++; break;
				case YN: blockPos.y--; break;
				case ZP: blockPos.z++; break;
				case ZN: blockPos.z--; break;
			}

			if (blockPos.x < 0 || blockPos.y < 0 || blockPos.z < 0 ||
				blockPos.x >= totalSize.x || blockPos.y >= totalSize.y || blockPos.z >= totalSize.z)
				continue;

			// Avoid duplicate entries by hashing position
			IntType key = (blockPos.z * totalSize.y + blockPos.y) * totalSize.x + blockPos.x;
			if (!blockPosKeys.contains(key))
			{
				blockPosKeys.insert(key);
				blockPosList.append(blockPos);
			}
		}

		obj_builder* builder = ObjType(obj_builder, global::mc_builder);
		builder->build_randomize = res->scenery_randomize;
		builder->build_multithreaded = null_;
		builder->build_edges = !(global::_app->setting_scenery_remove_edges && size.x > scenery_large_threshold && size.y > scenery_large_threshold);
		builder->block_tl_add = res->scenery_tl_all_types || res->scenery_tl_types.Arr().Size() > 0;
		builder->block_tl_types = res_get_block_timeline_types(Scope<obj_resource>(res));
		BoolType keepWater = !block_get_filtered(res->id, FindMap(ObjType(obj_minecraft_assets, global::mc_assets)->block_name_map)->Value("water"));

		const IntType bufferCount = e_block_depth_amount * e_block_vbuffer_amount;
		QHash<IntType, quint64> updatedVbuffers;
		QVector<ArrType> addedBlocksChanged;

		// Allocate a padded section grid, sharing empty storage for untouched sections
		Builder::offset = { 2, 2, 2 };
		Builder::size = { size.y + 2, size.x + 2, size.z + 2 };
		WorldVec padded = Builder::size + Builder::offset;
		Builder::sectionsDim = {
			(padded.x + SECTION_SIZEM1) / SECTION_SIZE,
			(padded.y + SECTION_SIZEM1) / SECTION_SIZE,
			(padded.z + SECTION_SIZEM1) / SECTION_SIZE
		};
		Builder::sectionsXY = Builder::sectionsDim.x * Builder::sectionsDim.y;
		Builder::sections.Alloc(Builder::sectionsXY * Builder::sectionsDim.z, false);

		QVector<IntType> buildSections;
		Section empty({ 0, 0, 0 }, { SECTION_SIZE, SECTION_SIZE, SECTION_SIZE });
		for (IntType s = 0; s < Builder::sections.Size(); s++)
			Builder::sections[s] = &empty;

		for (const WorldVec& blockPos : blockPosList)
		{
			WorldVec buildBlockPos = { size.y - 1 - blockPos.y % size.y, blockPos.x % size.x, blockPos.z % size.z };

			WorldVec repeatPos = { blockPos.x / size.x, blockPos.y / size.y, blockPos.z / size.z };
			IntType index = block_mesh_get_index(
				buildBlockPos.x, buildBlockPos.y, buildBlockPos.z,
				self->block_meshes_size.x, self->block_meshes_size.y
			);
			index += ((repeatPos.z * repeat.y + repeatPos.y) * repeat.x + repeatPos.x) * meshCount;

			// Create builder thread
			std::unique_ptr<obj_builder_thread> thread(new obj_builder_thread);
			Scope<obj_builder_thread> scope(thread.get(), self->id);
			thread->build_size = ArrType::From({ size.y, size.x, size.z });
			thread->build_size_xy = size.x * size.y;
			thread->build_size_total = size.x * size.y * size.z;
			thread->build_transform = true;
			thread->build_edit = true;
			thread->builder_scenery_legacy = legacy;
			thread->block_tl_map = ds_int_map_create();
			
			// Mask of affected vertex buffers
			quint64 usedVbuffers = 0;

			// Remove triangles, then regenerate new geometry
			for (IntType pass = 0; pass < 2; pass++)
			{
				BoolType removePass = (pass == 0);
				BoolType addPass = (pass == 1);
				thread->build_remove = removePass;
				thread->builder_scenery = removePass;
				ds_map_clear(thread->block_tl_map);

				// Discard the previous section before resolving the next one
				for (IntType sectionIndex : buildSections)
				{
					delete Builder::sections[sectionIndex];
					Builder::sections[sectionIndex] = &empty;
				}

				buildSections.clear();

				// Fill ordinary builder sections, retaining air and waterlogged palette entries
				for (IntType dz = -2; dz <= 2; dz++)
				for (IntType dy = -2; dy <= 2; dy++)
				for (IntType dx = -2; dx <= 2; dx++)
				{
					WorldVec bp = buildBlockPos + WorldVec(dx, dy, dz);
					if (bp.x < 0 || bp.y < 0 || bp.z < 0 || bp.x >= size.y || bp.y >= size.x || bp.z >= size.z)
						continue;

					WorldVec localBlockPos = WorldVec(bp.y, size.y - 1 - bp.x, bp.z) + repeatPos * size;
					BuilderState state = BlockMeshesGetBlock(self.object, localBlockPos.x, localBlockPos.y, localBlockPos.z, removePass && rebuild);

					// Retain source IDs for animated block exclusion
					BuilderState original = BlockMeshesGetBlock(self.object, localBlockPos.x, localBlockPos.y, localBlockPos.z, true);
					IntType sourceIndex = (bp.z * size.x + bp.y) * size.y + bp.x;
					ds_map_add(thread->block_tl_map, sourceIndex, (IntType)original.blockId);

					// Edited block
					if (addPass && adding && localBlockPos == editBlockPos)
						state = editState;
					
					// Match filter
					if (state.blockId && block_get_filtered(res->id, global::block_objs.Value(state.blockId)))
						state = { 0, 0, false };

					if (!keepWater)
						state.waterlogged = false;

					WorldVec shifted = bp + Builder::offset;
					WorldVec sectionPos = { shifted.x / SECTION_SIZE, shifted.y / SECTION_SIZE, shifted.z / SECTION_SIZE };
					IntType sectionIndex = sectionPos.z * Builder::sectionsXY + sectionPos.y * Builder::sectionsDim.x + sectionPos.x;
					
					Section*& section = Builder::sections[sectionIndex];
					if (section == &empty)
					{
						section = new Section(
							{ sectionPos.x * SECTION_SIZE, sectionPos.z * SECTION_SIZE, sectionPos.y * SECTION_SIZE },
							{ SECTION_SIZE, SECTION_SIZE, SECTION_SIZE }
						);
						section->AddBuilderState({ 0, 0, false });
						buildSections.append(sectionIndex);
					}
					
					section->builder.paletteIndices[section->GetBlockOffset(bp)] = section->AddBuilderState(state);
				}

				// Resolve culling models before neighbor-dependent states
				for (IntType stage = 0; stage < 2; stage++)
				for (IntType dz = -1; dz <= 1; dz++)
				for (IntType dy = -1; dy <= 1; dy++)
				for (IntType dx = -1; dx <= 1; dx++)
				{
					BoolType resolveStage = (stage == 0);
					BoolType genStage = (stage == 1);

					WorldVec bp = buildBlockPos + WorldVec(dx, dy, dz);
					thread->build_pos = ArrType::From({ bp.x, bp.y, bp.z });
					thread->build_pos_index = (bp.z * size.x + bp.y) * size.y + bp.x;

					builder_set_render_model(scope, bp.x, bp.y, bp.z, 0);
					builder_set_model(scope, genStage);
				}

				thread->build_pos = ArrType::From({ buildBlockPos.x, buildBlockPos.y, buildBlockPos.z });
				thread->build_pos_index = (buildBlockPos.z * size.x + buildBlockPos.y) * size.y + buildBlockPos.x;

				IntType modelIndex = builder_get_render_model_index(scope, buildBlockPos.x, buildBlockPos.y, buildBlockPos.z);
				ArrType models;
				if (modelIndex > 0)
					models.Append(modelIndex);
				else if (modelIndex < 0)
					models = builder_get_render_model_multipart(buildBlockPos.x, buildBlockPos.y, buildBlockPos.z, -modelIndex);
				
				for (IntType m = 0; m < models.Size(); m++)
				{
					obj_block_render_model* model = ObjType(obj_block_render_model, global::block_rendermodels.Value(models.IntValue(m)));
					for (IntType vb = 0; vb < bufferCount; vb++)
						if (model->block_vbuffer_used.BoolValue(vb))
							usedVbuffers |= quint64(1) << vb;
				}

				// Liquids emit geometry without a JSON render model
				BuilderState state = Builder::GetSection(buildBlockPos)->GetBuilderState(buildBlockPos);
				obj_block* block = Builder::blocks[state.blockId];
				if (state.waterlogged || (block && block->name == "water"))
					usedVbuffers |= quint64(1) << (e_block_depth_DEPTH2 * e_block_vbuffer_amount + e_block_vbuffer_WATER);
				
				if (block && block->name == "lava")
				{
					IntType slot = FindMap(ObjType(obj_minecraft_assets, global::mc_assets)->block_liquid_slot_map)->Value("lava");
					IntType depth = FindList(ObjType(obj_resource, global::mc_res)->block_sheet_ani_depth_list)->Value(slot);
					usedVbuffers |= quint64(1) << (depth * e_block_vbuffer_amount + e_block_vbuffer_ANIMATED);
				}

				obj_block_mesh* source = ObjTypeOpt(obj_block_mesh, self->block_meshes.Value(index));
				obj_block_mesh* mesh = ObjTypeOpt(obj_block_mesh, self->block_meshes_edit.Value(index));
				if (!mesh)
				{
					mesh = new obj_block_mesh;
					self->block_meshes_edit[index] = mesh->id;
				}

				thread->block_mesh = mesh->id;

				updatedVbuffers[index] |= usedVbuffers;

				// Copy only affected buffers; null buffers continue to use the source
				for (IntType vb = 0; vb < bufferCount; vb++)
				{
					if (!(usedVbuffers & (quint64(1) << vb)) || mesh->block_vbuffer.Value(vb) != null_)
						continue;

					VertexBuffer* vbuf;
					if (source&& source->block_vbuffer.Value(vb) != null_)
						vbuf = FindVertexBuffer(source->block_vbuffer.IntValue(vb))->Copy();
					else
						vbuf = new VertexBuffer;
					
					mesh->block_vbuffer[vb] = vbuf->id;
				}

				builder_generate(scope);

				if (addPass)
				{
					state = Builder::GetSection(buildBlockPos)->GetBuilderState(buildBlockPos);
					addedBlocksChanged.append(ArrType::From({ (VecType)blockPos, (IntType)state.blockId, (IntType)state.stateId }));
				}
			}

			ds_map_destroy(thread->block_tl_map);
		}

		// Release temporary sections before updating the timeline
		for (IntType sectionIndex : buildSections)
			delete Builder::sections[sectionIndex];
		
		Builder::sections.FreeData();
		Builder::offset = { 0, 0, 0 };
		builder->block_tl_types = null_;

		// Upload each changed buffer once and refresh the combined render order
		for (auto it = updatedVbuffers.constBegin(); it != updatedVbuffers.constEnd(); ++it)
		{
			IntType index = it.key();
			obj_block_mesh* source = ObjTypeOpt(obj_block_mesh, self->block_meshes.Value(index));
			obj_block_mesh* mesh = ObjType(obj_block_mesh, self->block_meshes_edit.Value(index));
			
			self->block_meshes_active[index] = false;
			mesh->block_vbuffer_render_order = ArrType();
			
			for (IntType d = 0; d < e_block_depth_amount; d++)
			{
				mesh->block_vbuffer_render_offsets[d] = mesh->block_vbuffer_render_order.Size();
				mesh->block_vbuffer_depth_active[d] = false;
				
				for (IntType vb = 0; vb < e_block_vbuffer_amount; vb++)
				{
					IntType slot = d * e_block_vbuffer_amount + vb;
					VertexBuffer* buffer = nullptr;

					if (mesh->block_vbuffer.Value(slot) != null_)
					{
						buffer = FindVertexBuffer(mesh->block_vbuffer.IntValue(slot));
						if (it.value() & (quint64(1) << slot))
							buffer->UpdateBuffers();
					}
					else if (source && source->block_vbuffer.Value(slot) != null_)
						buffer = FindVertexBuffer(source->block_vbuffer.IntValue(slot));
					
					mesh->block_vbuffer_active[slot] = buffer && buffer->numIndices > 0;
					if (!mesh->block_vbuffer_active.BoolValue(slot))
						continue;
					
					mesh->block_vbuffer_depth_active[d] = true;
					mesh->block_vbuffer_render_order.Append(slot);
					self->block_meshes_active[index] = true;
					
					if (d > e_block_depth_DEPTH0)
						self->block_meshes_transparent = true;
				}
			}

			mesh->block_vbuffer_render_offsets[e_block_depth_amount] = mesh->block_vbuffer_render_order.Size();
		}

		ArrType& addedPalette = self->blocks_added_palette;
		QHash<quint64, IntType> paletteIndices;
		for (IntType i = 0; i < addedPalette.Size(); i++)
		{
			const ArrType& entry = addedPalette.vec.Value(i).Arr();
			quint64 key = quint64(entry.IntValue(0)) | (quint64(entry.IntValue(1)) << 16);
			paletteIndices.insert(key, i);
		}

		for (const ArrType& changedBlock : addedBlocksChanged)
		{
			WorldVec blockPos = changedBlock.Value(0).ToVec();
			BuilderState original = BlockMeshesGetBlock(self.object, blockPos.x, blockPos.y, blockPos.z, false);
			BoolType selected = (adding && blockPos == editBlockPos);
			if (!selected && (changedBlock.IntValue(1) != original.blockId || changedBlock.IntValue(2) == original.stateId))
				continue;

			IntType blockId = changedBlock.IntValue(1);
			IntType stateId = changedBlock.IntValue(2);
			quint64 key = quint64(blockId) | (quint64(stateId) << 16);
			auto found = paletteIndices.constFind(key);
			IntType paletteIndex;
			if (found == paletteIndices.constEnd())
			{
				paletteIndex = addedPalette.Size();
				addedPalette.Append(ArrType::From({ blockId, stateId }));
				paletteIndices.insert(key, paletteIndex);
			}
			else
				paletteIndex = found.value();

			ArrType& blocksAdded = self->blocks_added;
			IntType addedIndex = -1;
			for (IntType i = 0; i < blocksAdded.Size(); i++)
			{
				WorldVec savedPos = blocksAdded.Value(i).Arr().Value(0).ToVec();
				if (savedPos == blockPos)
				{
					addedIndex = i;
					break;
				}
			}

			ArrType entry = ArrType::From({ (VecType)blockPos, paletteIndex });
			if (addedIndex < 0)
				blocksAdded.Append(entry);
			else
				blocksAdded[addedIndex] = entry;
		}

		// Retain referenced palette entries and remap block indices
		ArrType compactPalette, compactBlocks;
		QVector<IntType> paletteRemap(addedPalette.Size(), -1);
		for (IntType i = 0; i < self->blocks_added.Size(); i++)
		{
			const ArrType& entry = self->blocks_added.vec.Value(i).Arr();
			IntType oldIndex = entry.IntValue(1);

			// Drop air overrides when the source is already air
			if (!addedPalette.vec.Value(oldIndex).Arr().IntValue(0))
			{
				WorldVec blockPos = entry.Value(0).ToVec();
				if (!BlockMeshesGetBlock(self.object, blockPos.x, blockPos.y, blockPos.z, true).blockId)
					continue;
			}

			IntType& newIndex = paletteRemap[oldIndex];
			if (newIndex < 0)
			{
				newIndex = compactPalette.Size();
				compactPalette.Append(addedPalette.Value(oldIndex));
			}

			compactBlocks.Append(ArrType::From({ entry.Value(0), newIndex }));
		}
		self->blocks_added = compactBlocks;
		addedPalette = compactPalette;

		tl_update_render_blocks_transparent(self);

		if (adding)
			return ArrType::From({ (IntType)previous.blockId, (IntType)previous.stateId });

		return null_;
	}

	BoolType block_mesh_load_blocks(Scope<obj_block_mesh> self, IntType originx, IntType originy, IntType originz)
	{
		// Clear previous block data
		if (self->block_palette_buffer != null_)
			buffer_delete(self->block_palette_buffer);

		if (self->block_grid_buffer != null_)
			buffer_delete(self->block_grid_buffer);

		WorldVec size = {
			self->block_grid_size.Value(X_).ToInt(),
			self->block_grid_size.Value(Y_).ToInt(),
			self->block_grid_size.Value(Z_).ToInt()
		};

		// Keep temporary indices until the complete palette determines their bit width
		IntType sizeTotal = size.x * size.y * size.z;
		Heap<uint32_t> indices(sizeTotal);
		QVector<quint64> entries;
		QHash<quint64, uint32_t> palette;
		QHash<Section*, QVector<int>> sectionMappings;
		BoolType active = false;
		IntType blockPos = 0;

		// Visit blocks in XYZ order, with X varying fastest
		for (IntType zz = 0; zz < size.z; zz++)
		for (IntType yy = 0; yy < size.y; yy++)
		for (IntType xx = 0; xx < size.x;)
		{
			WorldVec pos = { originx + xx, originy + yy, originz + zz };
			Section* section = Builder::GetSection(pos);

			// Cache section-to-mesh palette mappings to avoid hashing every block
			auto mapping = sectionMappings.find(section);
			if (mapping == sectionMappings.end())
				mapping = sectionMappings.insert(section, QVector<int>(qMax(1, (int)section->builder.palette.Size()), -1));

			// Stop at the section boundary, accounting for an unaligned world selection
			IntType run = qMin(size.x - xx, SECTION_SIZE - ((pos.x + Builder::offset.x) & SECTION_SIZEM1));
			IntType offset = section->GetBlockOffset(pos);
			for (IntType i = 0; i < run; i++, blockPos++)
			{
				// Empty and single-entry sections do not need an index lookup
				int sourceIndex = 0;
				if (section->builder.palette.Size() > 1)
					sourceIndex = section->builder.paletteIndices[offset + i];

				int& index = mapping.value()[sourceIndex];
				if (index < 0)
				{
					BuilderState state;
					if (section->builder.palette.Size())
						state = section->builder.palette[sourceIndex];

					// Ignore unused state values on air blocks
					if (!state.blockId)
						state.stateId = 0;

					// Waterlogged and dry blocks need separate palette entries
					quint64 key = quint64(state.blockId) | (quint64(state.stateId) << 16) | (quint64(state.waterlogged) << 32);
					auto found = palette.constFind(key);
					if (found == palette.constEnd())
					{
						index = entries.size();
						entries.append(key);
						palette.insert(key, index);
					}
					else
						index = found.value();

					active |= (state.blockId != 0 || state.waterlogged);
				}

				indices[blockPos] = index;
			}

			xx += run;
		}

		// Use the minimum number of bits needed to address the palette
		int bits = 0;
		while ((1u << bits) < (uint32_t)entries.size())
			bits++;

		// Reserve whole bytes for the grid followed by one waterlogged bit per entry
		IntType gridBytes = (sizeTotal * bits + 7) / 8;
		Buffer* paletteBuffer = new Buffer(entries.size() * 4, false, 1);
		Buffer* gridBuffer = new Buffer(gridBytes + (entries.size() + 7) / 8, false, 1);
		self->block_palette_buffer = paletteBuffer->id;
		self->block_grid_buffer = gridBuffer->id;

		// Write each block/state pair as four little-endian bytes
		for (int i = 0; i < entries.size(); i++)
		{
			quint64 entry = entries[i];
			for (int b = 0; b < 4; b++)
				paletteBuffer->data[i * 4 + b] = (uchar)(entry >> (b * 8));

			// Store the waterlogged flag separately from the four-byte palette entry
			if (entry >> 32)
				gridBuffer->data[gridBytes + i / 8] |= 1 << (i % 8);
		}

		// Pack indices consecutively, including those that cross byte boundaries
		for (IntType p = 0; p < sizeTotal && bits > 0; p++)
		{
			uint32_t value = indices[p];
			IntType bitPos = p * bits;
			int remaining = bits;

			// Fill the available bits in each byte before advancing
			while (remaining > 0)
			{
				int shift = bitPos % 8;
				int take = qMin(remaining, 8 - shift);
				gridBuffer->data[bitPos / 8] |= (value & ((1u << take) - 1)) << shift;
				value >>= take;
				bitPos += take;
				remaining -= take;
			}
		}

		return active;
	}
}
