#include "World.hpp"
#include "NBT.hpp"

namespace CppProject
{
	WorldVec blockFaceOffset[Chunk::FaceDirectionAmount][4] = {
		{ { 1, 0, 1 }, { 1, 0, 0 }, { 1, 1, 0 }, { 1, 1, 1 } }, // Right
		{ { 0, 0, 0 }, { 0, 0, 1 }, { 0, 1, 1 }, { 0, 1, 0 } }, // Left
		{ { 0, 1, 1 }, { 1, 1, 1 }, { 1, 1, 0 }, { 0, 1, 0 } }, // Up
		{ { 1, 0, 0 }, { 1, 0, 1 }, { 0, 0, 1 }, { 0, 0, 0 } }, // Down
		{ { 0, 0, 1 }, { 1, 0, 1 }, { 1, 1, 1 }, { 0, 1, 1 } }, // Front
		{ { 1, 0, 0 }, { 0, 0, 0 }, { 0, 1, 0 }, { 1, 1, 0 } } // Back
	};
	WorldVec blockFaceMergeVec[Chunk::FaceDirectionAmount][2] = {
		{ { 0, 0, 1 }, { 0, 1, 0 } }, // Right
		{ { 0, 0, 1 }, { 0, 1, 0 } }, // Left
		{ { 1, 0, 0 }, { 0, 0, 1 } }, // Up
		{ { 1, 0, 0 }, { 0, 0, 1 } }, // Down
		{ { 1, 0, 0 }, { 0, 1, 0 } }, // Front
		{ { 1, 0, 0 }, { 0, 1, 0 } } // Back
	};

	Chunk::Chunk(Region* region, QByteArray& data, const WorldBox& box) : region(region)
	{
		memset(sections, 0, sizeof(sections));

		try
		{
			NbtStream stream(data, {
				{ TAG_BYTE, { "Y" } },
				{ TAG_BYTE_ARRAY, { "SkyLight", "BlockLight", "Blocks", "Data", "Biomes", "Add" }},
				{ TAG_COMPOUND, { "Level", "Properties", "block_states", "block_entities", "TileEntities", "biomes" }},
				{ TAG_LIST, { "sections", "Sections", "palette", "Palette" }},
				{ TAG_LONG_ARRAY, { "data", "BlockStates"}},
				{ TAG_STRING, { "Name", "Status" }},
				{ TAG_INT, { "DataVersion", "xPos", "zPos" }},
			});
			NbtCompound chunkCompound(stream);

			// Get block format
			format = region->anvilFormat ? JAVA_1_2 : PRE_JAVA_1_2;
			if (chunkCompound.HasKey("DataVersion"))
			{
				IntType dataVersion = chunkCompound.Int("DataVersion");
				if (dataVersion >= JAVA_1_18)
					format = JAVA_1_18;
				else if (dataVersion >= JAVA_1_16)
					format = JAVA_1_16;
				else if (dataVersion >= JAVA_1_13)
					format = JAVA_1_13;
			}

			// Use Level compound as root (removed in 1.18)
			NbtCompound* chunkRoot = chunkCompound.HasKey("Level") ? chunkCompound.Compound("Level") : &chunkCompound;

			// Get region offset
			x = ((IntType)chunkRoot->Int("xPos") & 31); // x % 32
			z = ((IntType)chunkRoot->Int("zPos") & 31); // z % 32
			rightEdge = (x == REGION_SIZE_CHUNKS - 1);
			leftEdge = (x == 0);
			frontEdge = (z == REGION_SIZE_CHUNKS - 1);
			backEdge = (z == 0);
			regionIndex = (z << 5) + x; // z * 32 + x

			// Get region position in blocks
			regionPos.x = x << 4; // x * 16
			regionPos.y = CHUNK_HEIGHT_MIN;
			regionPos.z = z << 4; // z * 16

			// Check chunk box with given selection
			WorldVec worldPos = region->pos + regionPos;
			if (box.active && !box.Intersects({ worldPos, worldPos + WorldVec(SECTION_SIZE, CHUNK_HEIGHT_SIZE, SECTION_SIZE) }))
				return;

			// Parse legacy 16x16 biomes
			if (chunkRoot->HasKey("Biomes"))
			{
				const Heap<int8_t>& biomesArray = chunkRoot->ByteArray("Biomes");
				const Map& legacyIdsMap = DsMap(global::legacy_biomes_ids_map);

				legacyBiomes.Alloc(SECTION_SIZE * SECTION_SIZE);
				for (IntType x = 0; x < SECTION_SIZE; x++)
				for (IntType z = 0; z < SECTION_SIZE; z++)
					legacyBiomes[z * SECTION_SIZE + x] = Preview::mcBiomeIdIndexMap[legacyIdsMap.Value(biomesArray.Value(z * SECTION_SIZE + x))];
			}
			
			// Parse existing sections
			if (format >= JAVA_1_2)
			{
				// Must be fully loaded
				if (chunkRoot->HasKey("Status")) {
					StringType status = chunkRoot->String("Status").Replaced("minecraft:", "");
					if (status != "full" &&
						status != "fullchunk" &&
						status != "postprocessed")
						return;
				}

				StringType sectionsName = (format >= JAVA_1_18 ? "sections" : "Sections");
				if (!chunkRoot->HasKey(sectionsName))
					return;

				QVector<NbtCompound*> sectionsList = chunkRoot->List<TAG_COMPOUND, NbtCompound>(sectionsName);
				for (NbtCompound* comp : sectionsList)
				{
					IntType y = comp->Byte("Y");
					if (y < CHUNK_SECTION_MIN || y >= CHUNK_SECTION_MIN + CHUNK_SECTIONS)
						continue;

					Section* section = new Section(this, y, box);
					sections[section->chunkIndex] = section;
					if (!section->Load(comp, format))
					{
						error = true;
						return;
					}
				}
			}

			// Parse block data arrays (16x16x128 before 1.2)
			else
				for (IntType y = 0; y < 128 / SECTION_SIZE; y++)
				{
					Section* section = new Section(this, y, box);
					sections[section->chunkIndex] = section;
					if (!section->Load(chunkRoot, format))
					{
						error = true;
						return;
					}
				}

			// Parse block entities if box is active
			if (box.active)
			{
				StringType blockEntitiesName = "block_entities";
				if (chunkRoot->HasKey("TileEntities"))
					blockEntitiesName = "TileEntities";

				QVector<NbtCompound*> blockEntities = chunkRoot->List<TAG_COMPOUND, NbtCompound>(blockEntitiesName);
				for (IntType i = 0; i < blockEntities.size(); i++)
				{
					NbtCompound* blockEntity = blockEntities.value(i);
					StringType id;
					WorldVec worldPos;

					// Get id and world position
					if (blockEntity->HasKey("id"))
					{
						id = blockEntity->String("id");
						worldPos = { blockEntity->Int("x"), blockEntity->Int("y"), blockEntity->Int("z")};
					}
					else
					{
						id = blockEntity->String("Id");
						QVector<NbtInt*> posList = blockEntity->List<TAG_INT, NbtInt>("Pos");
						worldPos = { posList[0]->value, posList[1]->value, posList[2]->value };
					}

					// Get script
					id = id.Replaced("minecraft:", "");
					IntType scriptId = asset_get_index("block_tile_entity_" + id.ToLower());

					// Create block entity relative to box start
					if (scriptId > -1 && box.Contains(worldPos))
					{
						this->blockEntities.append({
							worldPos - box.start,
							FindScript(scriptId),
							blockEntity
						});
						((NbtList*)chunkRoot->value[blockEntitiesName])->value.Erase(i); // Erase from list to avoid deletion
					}
				}
			}
			else
				// Add sections where needed for preview mesh generation
				for (IntType i = 0; i < CHUNK_SECTIONS; i++)
					if (!sections[i])
						sections[i] = new Section(this, i + CHUNK_SECTION_MIN, box);
		}
		catch (const QString& ex)
		{
			WARNING("Error reading chunk at " + NumStr(x) + ", " + NumStr(z) + ": " + ex);
			error = true;
			return;
		}
	}

	Chunk::~Chunk()
	{
		// Erase sections not needed by the scenery builder
		for (Section* section : sections)
			if (section && section->dataType != Section::BUILDER)
				delete section;
	}

	void Chunk::GeneratePreview(Region::GenerateMode mode)
	{
		// Find start and end XZ in the sections to generate
		WorldVec startPos = { 0, 0, 0 }, endPos = { SECTION_SIZE, SECTION_SIZE, SECTION_SIZE };

		if (mode < Region::GenerateMode::LEFT_BACK_CORNER)
		{
			// Check if chunk is on region edge, those blocks need other regions to be loaded first
			if (rightEdge)
				endPos.x--;
			else if (leftEdge)
				startPos.x++;
			if (frontEdge)
				endPos.z--;
			else if (backEdge)
				startPos.z++;
		}

		switch (mode)
		{
			// Region edges only
			case Region::GenerateMode::RIGHT_EDGE:
			{
				if (rightEdge)
					startPos.x = SECTION_SIZEM1, endPos.x = SECTION_SIZE;
				else
					return;
				break;
			}
			case Region::GenerateMode::LEFT_EDGE:
			{
				if (leftEdge)
					startPos.x = 0, endPos.x = 1;
				else
					return;
				break;
			}
			case Region::GenerateMode::FRONT_EDGE:
			{
				if (frontEdge)
					startPos.z = SECTION_SIZEM1, endPos.z = SECTION_SIZE;
				else
					return;
				break;
			}
			case Region::GenerateMode::BACK_EDGE:
			{
				if (backEdge)
					startPos.z = 0, endPos.z = 1;
				else
					return;
				break;
			}

			// Region corners only
			case Region::GenerateMode::LEFT_BACK_CORNER:
			{
				if (leftEdge && backEdge)
					endPos.x = 1, endPos.z = 1;
				else
					return;
				break;
			}
			case Region::GenerateMode::RIGHT_BACK_CORNER:
			{
				if (rightEdge && backEdge)
					startPos.x = SECTION_SIZEM1, endPos.z = 1;
				else
					return;
				break;
			}
			case Region::GenerateMode::RIGHT_FRONT_CORNER:
			{
				if (rightEdge && frontEdge)
					startPos.x = SECTION_SIZEM1, startPos.z = SECTION_SIZEM1;
				else
					return;
				break;
			}
			case Region::GenerateMode::LEFT_FRONT_CORNER:
			{
				if (leftEdge && frontEdge)
					startPos.z = SECTION_SIZEM1, endPos.x = 1;
				else
					return;
				break;
			}
		}

		// Calculate face/vertex data dimensions per section
		faceDataSizeX = endPos.x - startPos.x;
		faceDataSizeXZ = faceDataSizeX * (endPos.z - startPos.z);
		faceDataSizeTotal = faceDataSizeXZ * SECTION_SIZE;
		vertexDataSizeX = endPos.x + 1 - startPos.x;
		vertexDataSizeXZ = vertexDataSizeX * (endPos.z + 1 - startPos.z);
		vertexDataSizeTotal = vertexDataSizeXZ * SECTION_SIZE;

		// Allocate face/vertex data for each section
		for (IntType m = 0; m < Region::MeshTypeAmount; m++)
		{
			for (IntType s = 0; s < CHUNK_SECTIONS; s++)
			{
				if (Section* section = sections[s])
				{
					if (section->preview.hasBlocks && (m != Region::TRANSPARENT || section->preview.hasTransparent))
					{
						meshes[m].faceData[s].Alloc(faceDataSizeTotal);

						// Allocate vertex data for this section and next (to support Y=16 vertices outside section)
						if (!meshes[m].vertexData[s].Size())
							meshes[m].vertexData[s].Alloc(vertexDataSizeTotal);
						meshes[m].vertexData[s + 1].Alloc(vertexDataSizeTotal);
					}
				}
			}
		}

		// Generate block faces
		for (IntType s = 0; s < CHUNK_SECTIONS; s++)
			if (Section* section = sections[s])
				if (section->preview.hasBlocks)
					section->GenerateFaces(mode, startPos, endPos);

		for (Mesh& mesh : meshes)
		{
			mesh.vertices.Alloc(8192);
			mesh.indices.Alloc(4096);

			// Create triangles from faces
			for (uint8_t s = 0; s < CHUNK_SECTIONS; s++)
			{
				uint16_t sy = s * SECTION_SIZE;
				Heap<FaceData>& faceData = mesh.faceData[s];
				if (!faceData.Size())
					continue;

				// Right/Left face in XYZ order
				for (uint8_t x = startPos.x; x < endPos.x; x++)
				for (uint8_t y = 0; y < SECTION_SIZE; y++)
				for (uint8_t z = startPos.z; z < endPos.z; z++)
				{
					GenerateFaceTriangles(mesh, RIGHT, faceData, x, sy + y, z, startPos, endPos);
					GenerateFaceTriangles(mesh, LEFT, faceData, x, sy + y, z, startPos, endPos);
				}

				// Top/Bottom face in YZX order
				for (uint8_t y = 0; y < SECTION_SIZE; y++)
				for (uint8_t z = startPos.z; z < endPos.z; z++)
				for (uint8_t x = startPos.x; x < endPos.x; x++)
				{
					GenerateFaceTriangles(mesh, TOP, faceData, x, sy + y, z, startPos, endPos);
					GenerateFaceTriangles(mesh, BOTTOM, faceData, x, sy + y, z, startPos, endPos);
				}

				// Front/Back face in ZYX order
				for (uint8_t z = startPos.z; z < endPos.z; z++)
				for (uint8_t y = 0; y < SECTION_SIZE; y++)
				for (uint8_t x = startPos.x; x < endPos.x; x++)
				{
					GenerateFaceTriangles(mesh, FRONT, faceData, x, sy + y, z, startPos, endPos);
					GenerateFaceTriangles(mesh, BACK, faceData, x, sy + y, z, startPos, endPos);
				}
			}

			// Free data
			for (uint8_t s = 0; s < CHUNK_SECTIONS; s++)
			{
				mesh.faceData[s].FreeData();
				mesh.vertexData[s].FreeData();
			}
		}
	}

	void Chunk::GenerateFaceTriangles(Mesh& mesh, Chunk::FaceDirection dir, Heap<FaceData>& faceData, uint16_t x, uint16_t y, uint16_t z, const WorldVec& startPos, const WorldVec& endPos)
	{
		IntType faceDataIndex = (y & SECTION_SIZEM1) * faceDataSizeXZ + (z - startPos.z) * faceDataSizeX + (x - startPos.x);
		const uint16_t& blockData = faceData.Value(faceDataIndex).blockData[dir];
		if (!blockData)
			return;

		// Make face as big as possible by merging with identical data
		WorldVec faceOffset = { 0, 0, 0 };
		WorldVec pos = { x, y, z };

		// Returns whether the current data is equal to another face at a given position in the chunk
		auto faceMatch = [&](const WorldVec& pos, uint16_t*& outBlockData)
		{
			if (pos.x < startPos.x || pos.y < 0 || pos.z < startPos.z ||
				pos.x == endPos.x || pos.y >= CHUNK_HEIGHT_SIZE || pos.z == endPos.z)
				return false;

			uint8_t sectionIndex = pos.y / SECTION_SIZE;
			if (!mesh.faceData[sectionIndex].Size()) // No faces in target section
				return false;

			uint16_t faceDataIndex = (pos.y & SECTION_SIZEM1) * faceDataSizeXZ + (pos.z - startPos.z) * faceDataSizeX + (pos.x - startPos.x);
			outBlockData = &mesh.faceData[sectionIndex][faceDataIndex].blockData[dir];
			return *outBlockData == blockData;
		};

		// Resize in first direction
		uint8_t d0;
		for (d0 = 1; d0 < SECTION_SIZE; d0++)
		{
			WorldVec offset = blockFaceMergeVec[dir][0] * d0;
			uint16_t* offsetBlockData = nullptr;
			if (!faceMatch(pos + offset, offsetBlockData))
				break;
		
			*offsetBlockData = 0; // Erase data of face
			faceOffset = offset;
		}
		
		// Resize in second direction
		uint16_t* offsetBlockData[SECTION_SIZE];
		for (uint8_t d1 = 1, d2; d1 < SECTION_SIZE; d1++)
		{
			WorldVec offset = blockFaceMergeVec[dir][1] * d1;
			BoolType exit = false;
			for (d2 = 0; d2 < d0; d2++) // Check faces in first direction
			{
				if (!faceMatch(pos + offset, offsetBlockData[d2]))
				{
					exit = true;
					break;
				}
				offset = offset + blockFaceMergeVec[dir][0];
			}
			if (exit)
				break;
			for (uint8_t b = 0; b < d2; b++) // Erase data of row faces
				*(offsetBlockData[b]) = 0;
			faceOffset = faceOffset + blockFaceMergeVec[dir][1];
		}

		// Add vertices of face
		uint32_t index[4];
		WorldVec faceSize = faceOffset + 1;
		for (uint8_t c = 0; c < 4; c++)
		{
			const WorldVec& cornerVec = blockFaceOffset[dir][c];
			WorldVec vertPos = pos + cornerVec * faceSize;
			IntType vertexDataIndex = (vertPos.y & SECTION_SIZEM1) * vertexDataSizeXZ + (vertPos.z - startPos.z) * vertexDataSizeX + (vertPos.x - startPos.x);
			VertexData& vertexData = mesh.vertexData[vertPos.y / SECTION_SIZE][vertexDataIndex];

			if (!vertexData.blockData) // First use of vertex
			{
				vertexData.blockData = blockData;
				vertexData.index = index[c] = mesh.vertices.Append({ regionPos + vertPos, blockData });
			}
			else if (vertexData.blockData == blockData) // Re-use vertex
				index[c] = vertexData.index;

			else // Unique, add new
				index[c] = mesh.vertices.Append({ regionPos + vertPos, blockData });
		}

		// Add indices for two triangles
		mesh.indices.Append(index[0]);
		mesh.indices.Append(index[1]);
		mesh.indices.Append(index[2]);
		mesh.indices.Append(index[2]);
		mesh.indices.Append(index[3]);
		mesh.indices.Append(index[0]);
	}

	void Chunk::FreePreviewData()
	{
		// Section data on edges may be needed for new regions
		if (region->generatedAmount < Region::GenerateModeAmount && (leftEdge || rightEdge || backEdge || frontEdge))
			return;

		// Free mesh generation data
		for (IntType i = 0; i < CHUNK_SECTIONS; i++)
		{
			if (Section* section = sections[i])
			{
				section->preview.blockStyleIndices.FreeData();
				section->preview.states.FreeData();
				section->preview.biomeIndices.FreeData();
			}
		}
	}
}
