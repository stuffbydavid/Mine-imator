#include "World.hpp"

#include "GZIP.hpp"
#include "NBT.hpp"
#include "Render/Mesh.hpp"

namespace CppProject
{
	RegionLoader* Region::loader;

	Region::Region(QString filename) : filename(filename)
	{
		// Retrieve position of region from filename
		QRegularExpressionMatch match = QRegularExpression("r.(-?\\d+)\\.(-?\\d+)\\..*").match(filename);
		x = (IntType)match.captured(1).toInt();
		z = (IntType)match.captured(2).toInt();
		name = "Region(" + NumStr(x) + ", " + NumStr(z) + ")";
		anvilFormat = filename.endsWith(".mca");

		// Find dimension
		if (filename.contains("DIM-1/"))
			dimName = "nether";
		else if (filename.contains("DIM1/"))
			dimName = "end";
		else
			dimName = "overworld";

		// Position in blocks
		pos = { x * REGION_SIZE, 0, z * REGION_SIZE };

		memset(generated, 0, sizeof(generated));
		memset(chunks, 0, sizeof(chunks));
		memset(adjacent, 0, sizeof(adjacent));
	}

	Region::~Region()
	{
		Unload();
	}

	void Region::Unload()
	{
		if (loadStatus != LOADED)
			return;

		for (MeshData& mData : meshData)
		{
			mData.numVertices = mData.mesh.numVertices = 0;
			mData.numIndices = mData.mesh.numIndices = 0;
			mData.mesh.FreeBuffers();
			mData.loaded = false;
		}

		for (Chunk* chunk : chunks)
			if (chunk)
				delete chunk;
		memset(chunks, 0, sizeof(chunks));

		if (Region* right = adjacent[RIGHT])
			right->adjacent[LEFT] = nullptr;
		if (Region* left = adjacent[LEFT])
			left->adjacent[RIGHT] = nullptr;
		if (Region* front = adjacent[FRONT])
			front->adjacent[BACK] = nullptr;
		if (Region* back = adjacent[BACK])
			back->adjacent[FRONT] = nullptr;

		loadStatus = UNLOADED;
		meshStatus = NOMESH;
		generatedAmount = 0;
		unload = false;
	}

	void Region::Load(const WorldBox& box)
	{
		// Check region box with given selection
		if (box.active && !box.Intersects({ pos + WorldVec(0, CHUNK_HEIGHT_MIN, 0), pos + WorldVec(REGION_SIZE, CHUNK_HEIGHT_MAX, REGION_SIZE) }))
			return;

		Unload();

		memset(chunkStatus, 0, sizeof(chunkStatus));
		memset(loadedSections, 0, sizeof(loadedSections));
		memset(adjacent, 0, sizeof(adjacent));
		memset(generated, 0, sizeof(generated));

		loadProgress = loadProgressTarget = 0.0;

		QFile file(filename);
		if (!file.open(QFile::ReadOnly) || !file.size())
		{
			WARNING("Could not open " + filename);
			loadStatus = LOAD_ERROR;
			return;
		}

		QByteArray data = file.readAll();

		// Read chunk offsets
		QVector<IntType> offsets;
		uint16_t maxChunks = 32 * 32;
		for (uint16_t i = 0; i < maxChunks; i++)
		{
			uint8_t b1, b2, b3;
			b1 = data.at(i * 4 + 0);
			b2 = data.at(i * 4 + 1);
			b3 = data.at(i * 4 + 2);
			IntType offset = ((b1 << 16) | (b2 << 8) | b3) << 12;
			if (offset > 0)
				offsets.append(offset);
		}

		numChunks = offsets.size();

		// Load chunks
		IntType numTimelines = 0;
		Timer tmr;
		StringType::BeginOmp();

		#pragma OPENMP_FOR reduction(+:numTimelines)
		for (IntType i = 0; i < numChunks; i++)
		{
			IntType offset = offsets[i];
			uint8_t b1, b2, b3, b4;
			b1 = data.at(offset + 0);
			b2 = data.at(offset + 1);
			b3 = data.at(offset + 2);
			b4 = data.at(offset + 3);
			IntType length = (b1 << 24) | (b2 << 16) | (b3 << 8) | b4;

			QByteArray chunkData;
			if (!Gzip::Decompress(data.constData() + offset + 5, length - 1, chunkData))
			{
				WARNING("Error decompressing chunk");
				continue;
			}

			Chunk* chunk = new Chunk(this, chunkData, box);
			chunks[chunk->regionIndex] = chunk;
			chunkStatus[chunk->regionIndex] = ChunkStatus::CHUNK_LOADED;
			numTimelines += chunk->numTimelines;
		}

		StringType::EndOmp();

		// Create block entity maps on main thread
		for (Chunk* chunk : chunks)
		{
			if (!chunk)
				continue;

			// Legacy (pre-flattening) region
			if (chunk->format < Chunk::JAVA_1_13)
				legacy = true;

			for (BlockEntity& entity : chunk->blockEntities)
			{
				entity.map = entity.nbt->ToMap();
				delete entity.nbt;
			}
		}

		loadStatus = LOADED;
		this->numTimelines = numTimelines;

		tmr.Print(name + " read " + NumStr(offsets.size()) + " chunks");

		// Create meshes for preview
		if (!box.active)
		{
			GeneratePreview(FIRST);

			// Update neighbors
			if (Region* right = Find(x + 1, z, LOADED))
			{
				right->AddAdjacent(LEFT, this);
				this->AddAdjacent(RIGHT, right);
			}
			if (Region* left = Find(x - 1, z, LOADED))
			{
				left->AddAdjacent(RIGHT, this);
				this->AddAdjacent(LEFT, left);
			}
			if (Region* front = Find(x, z + 1, LOADED))
			{
				front->AddAdjacent(BACK, this);
				this->AddAdjacent(FRONT, front);
			}
			if (Region* back = Find(x, z - 1, LOADED))
			{
				back->AddAdjacent(FRONT, this);
				this->AddAdjacent(BACK, back);
			}
		}
	}

	RealType Region::GetLoadProgress()
	{
		// Get animated progress value from sum of all chunk statuses
		if (numChunks && loadProgressTarget < 1.0)
		{
			IntType total = numChunks * ChunkStatus::CHUNK_MESH_COPIED;
			IntType progress = 0;
			for (const ChunkStatus& status : chunkStatus)
				progress += status;

			loadProgressTarget = (RealType)progress / total;
		}

		loadProgress += (loadProgressTarget - loadProgress) / 2.0;
		return loadProgress;
	}

	void Region::GeneratePreview(GenerateMode mode)
	{
		if (generated[mode])
			return;

		// Generate chunk triangles
		StringType::BeginOmp();

		#pragma OPENMP_FOR
		for (IntType i = 0; i < REGION_CHUNKS; i++)
		{
			if (chunks[i] && !chunks[i]->error)
			{
				chunks[i]->GeneratePreview(mode);
				chunkStatus[i] = ChunkStatus::CHUNK_MESH_READY;
			}
		}
		StringType::EndOmp();

		meshStatus = UPDATE_MESH;
		generated[mode] = true;
		generatedAmount++;
	}

	void Region::UpdateMesh()
	{
		if (updateBuffers)
			return;

		for (uint8_t m = 0; m < MeshTypeAmount; m++)
		{
			MeshData& mData = meshData[m];
			mData.loaded = true;

			// Get new region mesh size and apply offsets to chunk meshes
			for (Chunk* chunk : chunks)
			{
				if (!chunk)
					continue;

				Chunk::Mesh& chunkMesh = chunk->meshes[m];
				chunkMesh.vertexOffset = mData.numVertices;
				chunkMesh.indexOffset = mData.numIndices;
				if (!chunkMesh.indices.Size())
					continue;

				mData.numVertices += chunkMesh.vertices.Size();
				mData.numIndices += chunkMesh.indices.Size();
				mData.changed = true;
			}

			// Allocate new size
			if (mData.changed)
			{
				mData.mesh.vertexData.Alloc(mData.numVertices);
				mData.mesh.indexData.Alloc(mData.numIndices);
			}

			// Copy chunk data to region mesh
			#pragma OPENMP_FOR
			for (int16_t i = 0; i < REGION_CHUNKS; i++)
			{
				Chunk* chunk = chunks[i];
				if (!chunk)
					continue;

				Chunk::Mesh& chunkMesh = chunk->meshes[m];
				if (chunkMesh.indices.Size())
				{
					// Vertices
					mData.mesh.vertexData.Copy(chunkMesh.vertices.heap, chunkMesh.vertices.Size(), 0, chunkMesh.vertexOffset);
					chunkMesh.vertices.Clear();

					// Indices
					mData.mesh.indexData.Copy(chunkMesh.indices.heap, chunkMesh.indices.Size(), 0, chunkMesh.indexOffset);
					if (chunkMesh.vertexOffset)
						for (IntType i = 0; i < chunkMesh.indices.Size(); i++)
							mData.mesh.indexData[chunkMesh.indexOffset + i] += chunkMesh.vertexOffset;
					chunkMesh.indices.Clear();
				}

				chunkStatus[i] = ChunkStatus::CHUNK_MESH_COPIED;
			}
		}


		// Free unused data
		for (Chunk* chunk : chunks)
			if (chunk)
				chunk->FreePreviewData();

		meshStatus = UPDATE_BUFFERS;
	}

	void Region::UpdateBuffers()
	{
		updateBuffers = true;

		// Create/Update OpenGL buffers, must be done on main thread so this is split from UpdateMesh()
		for (uint8_t m = 0; m < MeshTypeAmount; m++)
		{
			MeshData& mData = meshData[m];
			if (!mData.changed)
				continue;

			// Release old GPU buffers
			if (mData.mesh.HasBuffers())
				mData.mesh.FreeBuffers(false);

			// Free CPU data if mesh is fully generated
			mData.mesh.numVertices = mData.numVertices;
			mData.mesh.numIndices = mData.numIndices;
			WorldVec boundsPos = pos + WorldVec(0, CHUNK_HEIGHT_MIN, 0);
			mData.mesh.bounds = Bounds(boundsPos, boundsPos + VecType(REGION_SIZE, CHUNK_HEIGHT_SIZE, REGION_SIZE));
			mData.mesh.CreateBuffers(generatedAmount == GenerateModeAmount);
			mData.changed = false;
		}

		meshStatus = READY;
		updateBuffers = false;
	}

	void Region::AddAdjacent(Direction direction, Region* region)
	{
		adjacent[direction] = region;

		switch (direction)
		{
			case RIGHT:
			{
				GeneratePreview(RIGHT_EDGE);
				if (adjacent[BACK])
					GeneratePreview(RIGHT_BACK_CORNER);
				if (adjacent[FRONT])
					GeneratePreview(RIGHT_FRONT_CORNER);
				break;
			}
			case LEFT:
			{
				GeneratePreview(LEFT_EDGE);
				if (adjacent[BACK])
					GeneratePreview(LEFT_BACK_CORNER);
				if (adjacent[FRONT])
					GeneratePreview(LEFT_FRONT_CORNER);
				break;
			}
			case FRONT:
			{
				GeneratePreview(FRONT_EDGE);
				if (adjacent[LEFT])
					GeneratePreview(LEFT_FRONT_CORNER);
				if (adjacent[RIGHT])
					GeneratePreview(RIGHT_FRONT_CORNER);
				break;
			}
			case BACK:
			{
				GeneratePreview(BACK_EDGE);
				if (adjacent[LEFT])
					GeneratePreview(LEFT_BACK_CORNER);
				if (adjacent[RIGHT])
					GeneratePreview(RIGHT_BACK_CORNER);
				break;
			}
		}
	}

	PreviewState Region::GetPreviewState(const WorldVec& pos, GenerateMode mode)
	{
		// Outside height bounds
		if (pos.y >= CHUNK_HEIGHT_MAX)
			return { false, false, false, 15 }; // Fully lit air
		if (pos.y < CHUNK_HEIGHT_MIN)
			return { true, true, false, 0 }; // Solid

		if (mode != GenerateMode::FIRST)
		{
			// Wrap right/left
			if (pos.x >= REGION_SIZE)
			{
				if (adjacent[RIGHT])
					return adjacent[RIGHT]->GetPreviewState({ 0, pos.y, pos.z }, mode);
				WARNING("Region: IsSolid out of bounds");
			}
			if (pos.x < 0)
			{
				if (adjacent[LEFT])
					return adjacent[LEFT]->GetPreviewState({ REGION_SIZE - 1, pos.y, pos.z}, mode);
				WARNING("Region: IsSolid out of bounds");
			}

			// Wrap front/back
			if (pos.z >= REGION_SIZE)
			{
				if (adjacent[FRONT])
					return adjacent[FRONT]->GetPreviewState({ pos.x, pos.y, 0 }, mode);
				WARNING("Region: IsSolid out of bounds");
			}
			if (pos.z < 0)
			{
				if (adjacent[BACK])
					return adjacent[BACK]->GetPreviewState({ pos.x, pos.y, REGION_SIZE - 1 }, mode);
				WARNING("Region: IsSolid out of bounds");
			}
		}
		
		// Find section
		uint16_t sectionIndex = (((pos.y >> 4) - CHUNK_SECTION_MIN) << 10) + ((pos.z >> 4) << 5) + (pos.x >> 4);
		Section* section = loadedSections[sectionIndex];
		if (!section) // Not loaded
			return { true, true, false, 0 }; // Solid

		// Find style in section
		uint16_t blockIndex = ((pos.y & SECTION_SIZEM1) << 8) + ((pos.z & SECTION_SIZEM1) << 4) + (pos.x & SECTION_SIZEM1); // YZX order
		if (section->preview.blockStyleIndices.Size())
			return section->preview.states.Value(blockIndex);
		else
			return section->preview.singleState;
	}

	Region* Region::Find(IntType x, IntType z, LoadStatus loadStatus)
	{
		for (Region* region : World::regions)
			if (region->x == x && region->z == z && region->loadStatus == loadStatus)
				return region;

		return nullptr;
	}
}