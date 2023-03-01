#include "World.hpp"

#include "AppHandler.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Asset/Buffer.hpp"
#include "GZIP.hpp"

#define BLOCK_MESH_CACHE_ENABLED 1
#define BLOCK_MESH_CACHE_FORMAT 2

namespace CppProject
{
	Heap<Section*> Builder::sections;
	WorldVec Builder::size, Builder::offset = { 0, 0, 0 }, Builder::sectionsDim;
	IntType Builder::sectionsXY;
	QHash<StringType, obj_block*> Builder::mcBlockIdObjMap, Builder::filteredMcBlockIdObjMap;
	QHash<StringType, ArrType> Builder::mcBlockIdStateVarsMap;
	Heap<obj_block*> Builder::blocks;
	Heap<obj_block_render_model*> Builder::renderModels;
	obj_block* Builder::filteredMcLegacyBlockIdObj[256][16];

	Section* Builder::GetSection(const WorldVec& pos)
	{
		IntType sectionX, sectionY, sectionZ, sectionPos;
		WorldVec posOffset = pos + offset;
		sectionX = posOffset.x >> 4;
		sectionY = posOffset.y >> 4;
		sectionZ = posOffset.z >> 4;
		sectionPos = sectionZ * Builder::sectionsXY + sectionY * Builder::sectionsDim.x + sectionX;

		return Builder::sections.Value(sectionPos);
	}

	void builder_create_buffers(Scope<obj_builder> self)
	{
		// Get dimensions from given x/y/z size with offset
		Builder::size = {
			self->build_size_x,
			self->build_size_y,
			self->build_size_z
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
			IntType lastSizeX = self->build_size_x % SECTION_SIZE;
			IntType lastSizeY = self->build_size_y % SECTION_SIZE;
			IntType lastSizeZ = self->build_size_z % SECTION_SIZE;
			if (!lastSizeX)
				lastSizeX = SECTION_SIZE;
			if (!lastSizeY)
				lastSizeY = SECTION_SIZE;
			if (!lastSizeZ)
				lastSizeZ = SECTION_SIZE;

			// Check if single block
			BuilderState singleEntry;
			if (self->build_single_block != null_)
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
					{ (x < Builder::sectionsDim.x - 1) ? SECTION_SIZE : lastSizeX,
					  (z < Builder::sectionsDim.z - 1) ? SECTION_SIZE : lastSizeZ,
					  (y < Builder::sectionsDim.y - 1) ? SECTION_SIZE : lastSizeY }
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
		self->build_pos = position;
		self->build_pos_x = self->build_pos % self->build_size_x;
		self->build_pos_y = (self->build_pos / self->build_size_x) % self->build_size_y;
		self->build_pos_z =self->build_pos / self->build_size_xy;
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
				paletteStateIds[i] = self->sch_palette_stateids[i];
				paletteWaterlogged[i] = self->sch_palette_waterlogged[i];
			}
		}

		IntType blockDataArray = self->sch_blockdata_array;
		IntType legacyBlockArray = self->sch_legacy_blocksarray;
		IntType legacyDataArray = self->sch_legacy_dataarray;

		// Populate sections with schematic data
		#pragma OPENMP_FOR reduction(+:numTimelines)
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
				IntType bufferPos = bz * self->build_size_xy + by * self->build_size_x + bx;

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
					if (paletteIndex > 0)
					{
						block = ObjTypeOpt(obj_block, paletteBlocks[paletteIndex]);
						state.stateId = paletteStateIds[paletteIndex];
						state.waterlogged = paletteWaterlogged[paletteIndex];
					}
				}
				else
				{
					// Get block from legacy id+data
					uint8_t legacyId = buffer->data[legacyBlockArray + bufferPos];
					if (legacyId > 0 && global::legacy_block_set[legacyId])
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
		self->build_size_y = buffer_read_short_be(); // Derp
		self->build_size_x = buffer_read_short_be();
		self->build_size_z = buffer_read_short_be();
		IntType blockData = buffer->pos;

		builder_start(self);

		// Populate sections with legacy blocks
		#pragma OPENMP_FOR reduction(+:numTimelines)
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
				IntType bufferPos = bz * self->build_size_xy + by * self->build_size_x + bx;
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
		if (index <= 0)
			return null_;

		return Builder::renderModels[index]->id;
	}

	ArrType builder_get_render_model_multipart(IntType x, IntType y, IntType z, IntType index)
	{
		return Builder::GetSection({ x, y, z })->builder.renderModelMultipartIds.Value(index);
	}

	IntType block_get_render_model(VarType object, RealType emissive, BoolType offset, BoolType offsetXY)
	{
		const ArrType& models = idVar(object, model).Arr();
		obj_block_render_model* model = nullptr;
		BoolType randBlocks = idVar(global::mc_builder, build_randomize);

		if (models.Size() > 1 && randBlocks)
		{
			// Pick a random model from the list
			IntType totalWeight = idVar(object, total_weight).ToInt();
			IntType rand = irandom(totalWeight - 1) + 1;
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

	Vertex builder_create_vertex(Scope<obj_builder_thread> self, RealType x, RealType y, RealType z, RealType tx, RealType ty, RealType nx, RealType ny, RealType nz)
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

		return Vertex{
			x, y, z,
			nx, ny, nz,
			self->block_vertex_rgb, self->block_vertex_alpha,
			tx, ty,
			wavexy, wavez, self->block_vertex_emissive, self->block_vertex_subsurface
		};
	}

	void builder_add_face(Scope<obj_builder_thread> self,
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

		// Add face
		FindVertexBuffer(self->block_vbuffer_current)->AddFace(
			builder_create_vertex(self, x1, y1, z1, tx1, ty1, nx, ny, nz),
			builder_create_vertex(self, x2, y2, z2, tx2, ty2, nx, ny, nz),
			builder_create_vertex(self, x3, y3, z3, tx3, ty3, nx, ny, nz),
			builder_create_vertex(self, x4, y4, z4, tx4, ty4, nx, ny, nz),
			self->threadid
		);
	}

	void builder_add_triangle(Scope<obj_builder_thread> self,
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

		// Add triangle
		FindVertexBuffer(self->block_vbuffer_current)->AddTriangle(
			builder_create_vertex(self, x1, y1, z1, tx1, ty1, nx, ny, nz),
			builder_create_vertex(self, x2, y2, z2, tx2, ty2, nx, ny, nz),
			builder_create_vertex(self, x3, y3, z3, tx3, ty3, nx, ny, nz),
			self->threadid
		);
	}

	BoolType res_load_scenery_world(Scope<obj_resource> self)
	{
		// Sections already generated
		if (Builder::sections.Size())
			return true;

		if (!QDir(self->world_regions_dir.Str()).exists())
			return false;

		World::Open((QString)self->world_regions_dir.Str());
		if (!World::regions.count())
		{
			World::Close();
			return false;
		}

		// Get box
		VecType boxStart = self->world_box_start;
		VecType boxEnd = self->world_box_end;
		if ((boxEnd - boxStart).GetLength() < 2)
		{
			World::Close();
			return false;
		}

		WorldBox box(WorldVec(boxStart.x, boxStart.y, boxStart.z), WorldVec(boxEnd.x, boxEnd.y, boxEnd.z));

		// Apply resource filters
		List& filterList = DsList(global::_app->setting_world_import_filter_list);
		BoolType oldFilterEnabled = global::_app->setting_world_import_filter_enabled;
		IntType oldFilterMode = global::_app->setting_world_import_filter_mode;
		auto oldFilterList = filterList.vec;

		global::_app->setting_world_import_filter_enabled = self->world_filter_array.Size() > 0;
		filterList.vec.clear();
		for (IntType i = 0; i < self->world_filter_array.Size(); i++)
			filterList.vec.append({ self->world_filter_array.Value(i), 0 });
		
		World::ApplyFilter();

		// Generate sections for scenery builder
		World::GenerateBuilderSections(box);

		// Restore settings
		global::_app->setting_world_import_filter_enabled = oldFilterEnabled;
		global::_app->setting_world_import_filter_mode = oldFilterMode;
		filterList.vec = oldFilterList;
		World::ApplyFilter();
		World::Close();

		return true;
	}

	void res_save_block_cache(Scope<obj_resource> self, StringType filename)
	{
	#if !BLOCK_MESH_CACHE_ENABLED
		return;
	#endif
		// Find required size
		obj_resource* res = self.object;
		IntType totalBytes = 0;
		RealType approxGzipRatio = 0.14;
		for (IntType d = 0; d < e_block_depth_amount; d++)
		for (IntType vb = 0; vb < e_block_vbuffer_amount; vb++)
			totalBytes += FindVertexBuffer(res->block_vbuffer.Value(d).Value(vb))->GetWriteBytes();
		IntType mb = ceil((totalBytes / 1000000.0) * approxGzipRatio);

		if (mb > 50)
		{
			if (!question(text_get({ "loadscenerysavecache", string(mb) + StringType("MB") })))
			{
				// CPU data of meshes won't be needed
				for (IntType d = 0; d < e_block_depth_amount; d++)
				for (IntType vb = 0; vb < e_block_vbuffer_amount; vb++)
					if (VertexBuffer* buf = FindVertexBuffer(res->block_vbuffer.Value(d).Value(vb)))
						for (Mesh<>* mesh : buf->meshes)
						{
							mesh->vertexData.FreeData();
							mesh->indexData.FreeData();
						}
				return;
			}
		}

		Timer tmr;
		QByteArray data;
		QDataStream out(&data, QIODevice::WriteOnly);

		// Save format
		uchar format = BLOCK_MESH_CACHE_FORMAT;
		out << format;

		// Save size
		out << (qint64)res->scenery_size.x;
		out << (qint64)res->scenery_size.y;
		out << (qint64)res->scenery_size.z;

		// Write vertex buffers
		for (IntType d = 0; d < e_block_depth_amount; d++)
		for (IntType vb = 0; vb < e_block_vbuffer_amount; vb++)
			FindVertexBuffer(res->block_vbuffer.Value(d).Value(vb))->Write(out);

		tmr.Print("Write block mesh cache");

		// Compress on a new thread
		QThread* thread;
		QString outName = filename.QStr();
		QString tempName = (QString)gmlGlobal::game_save_id + QFileInfo(filename).fileName();
		thread = QThread::create([outName, tempName, data, &thread]
		{
			Timer tmr;
			QFile outFile(outName);
			QFile tempFile(tempName);
			AddPerms(tempFile);
			Gzip::Compress(data, tempName);
			AddPerms(outFile);
			outFile.remove();
			tempFile.copy(outName);
			tempFile.remove();
			tmr.Print("Compress block mesh cache");
		});
		thread->start();
	}

	BoolType res_load_block_cache(Scope<obj_resource> self, StringType filename)
	{
	#if !BLOCK_MESH_CACHE_ENABLED
		return false;
	#endif
		Timer tmr;
		QByteArray data;
		Gzip::Decompress(filename, data);
		tmr.Print("Unzip block mesh cache");
		tmr.Reset();
		QDataStream in(&data, QIODevice::ReadOnly);

		// Check format
		uchar format;
		in >> format;
		if (format != BLOCK_MESH_CACHE_FORMAT)
			return false;

		// Load size
		qint64 sizeX, sizeY, sizeZ;
		in >> sizeX;
		in >> sizeY;
		in >> sizeZ;
		self->scenery_size = { (RealType)sizeX, (RealType)sizeY, (RealType)sizeZ };

		// Load vertex buffers
		for (IntType d = 0; d < e_block_depth_amount; d++)
		for (IntType vb = 0; vb < e_block_vbuffer_amount; vb++)
		{
			vertex_delete_buffer(self->block_vbuffer[d][vb]);
			self->block_vbuffer[d][vb] = (new VertexBuffer(in))->id;
		}

		tmr.Print("Read block mesh cache");
		return true;
	}
}