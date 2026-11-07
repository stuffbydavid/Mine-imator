#include "World.hpp"
#include "NBT.hpp"

namespace CppProject
{
	template <typename T> static T* PreparePreviewData(Heap<T>& data, IntType size)
	{
		if (data.Size() < size)
			data.Alloc(size, false);

		memset(data.data, 0, size * sizeof(T));
		return data.data;
	}

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

	Chunk::Chunk(Region* region, QByteArray& data, const WorldBox& box, SchematicExport* schematic) : region(region)
	{
		memset(sections, 0, sizeof(sections));

		try
		{
			NbtStream stream(data);
			stream.previewOnly = (!box.active && !schematic);
			stream.includeEntities = (schematic != nullptr);

			if (stream.previewOnly)
			{
				stream.filter = {
					{ TAG_BYTE, { "Y" } },
					{ TAG_BYTE_ARRAY, { "SkyLight", "BlockLight", "Blocks", "Data", "Biomes", "Add" }},
					{ TAG_COMPOUND, { "Level", "properties", "Properties", "block_states", "biomes" }},
					{ TAG_LIST, { "sections", "Sections", "palette", "Palette" }},
					{ TAG_LONG_ARRAY, { "data", "BlockStates"}},
					{ TAG_STRING, { "Name", "id", "Status", "", "waterlogged" }},
					{ TAG_INT, { "DataVersion", "xPos", "zPos" }},
				};
			}

			if (schematic)
				stream.stripNamespace = false;

			if (box.active)
			{
				// Floor negative heights and exclude the selection's end boundary
				stream.sectionMin = IntType(std::floor(RealType(box.start.y) / SECTION_SIZE));
				stream.sectionMax = IntType(std::floor(RealType(box.end.y - 1) / SECTION_SIZE));
			}

			NbtCompound chunkCompound(stream, box.active ? NbtStream::CHUNK : NbtStream::GENERIC);

			if (schematic && stream.ds.status() != QDataStream::Ok)
				throw QString("Truncated chunk NBT");

			// Get block format
			format = region->anvilFormat ? JAVA_1_2 : PRE_JAVA_1_2;
			if (chunkCompound.HasKey("DataVersion"))
			{
				dataVersion = chunkCompound.Int("DataVersion");

				if (dataVersion >= JAVA_26_3)
					format = JAVA_26_3; 
				else if (dataVersion >= JAVA_1_18)
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
			regionIndex = z * REGION_SIZE_CHUNKS + x;

			// Keep raw source data for export, applying block filters later
			if (schematic)
			{
				exportData = new NbtCompound;
				exportData->value.swap(chunkRoot->value);
				return;
			}


			rightEdge = (x == REGION_SIZE_CHUNKS - 1);
			leftEdge = (x == 0);
			frontEdge = (z == REGION_SIZE_CHUNKS - 1);
			backEdge = (z == 0);
			
			// Get region position in blocks
			regionPos.x = x * SECTION_SIZE;
			regionPos.y = CHUNK_HEIGHT_MIN;
			regionPos.z = z * SECTION_SIZE;

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
				if (chunkRoot->HasKey("Status"))
				{
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
		delete exportData;

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

		// Reuse scratch storage per worker instead of retaining it in every loaded chunk
		struct Scratch
		{
			Heap<FaceData> faceData[CHUNK_SECTIONS];
			Heap<VertexData> vertexData[CHUNK_SECTIONS + 1];
		};
		static thread_local Scratch scratch[Region::MeshTypeAmount];

		// Clear active sections, including the extra top boundary vertex slice
		for (IntType m = 0; m < Region::MeshTypeAmount; m++)
		{
			Mesh& mesh = meshes[m];
			memset(mesh.faceDirections, 0, sizeof(mesh.faceDirections));

			for (IntType s = 0; s < CHUNK_SECTIONS; s++)
			{
				if (Section* section = sections[s])
				{
					if (section->preview.hasBlocks && (m != Region::TRANSPARENT || section->preview.hasTransparent))
					{
						mesh.faceData[s] = PreparePreviewData(scratch[m].faceData[s], faceDataSizeTotal);

						// Allocate vertex data for this section and next (to support Y=16 vertices outside section)
						if (!mesh.vertexData[s])
							mesh.vertexData[s] = PreparePreviewData(scratch[m].vertexData[s], vertexDataSizeTotal);

						mesh.vertexData[s + 1] = PreparePreviewData(scratch[m].vertexData[s + 1], vertexDataSizeTotal);
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
			// Create triangles from faces
			for (uint8_t s = 0; s < CHUNK_SECTIONS; s++)
			{
				uint16_t sy = s * SECTION_SIZE;
				FaceData* faceData = mesh.faceData[s];
				
				uint8_t directions = mesh.faceDirections[s];
				if (!directions)
					continue;

				// Right/Left face in XYZ order
				if (directions & ((1 << RIGHT) | (1 << LEFT)))
				{
					for (uint8_t x = startPos.x; x < endPos.x; x++)
					for (uint8_t y = 0; y < SECTION_SIZE; y++)
					for (uint8_t z = startPos.z; z < endPos.z; z++)
					{
						const FaceData& face = faceData[y * faceDataSizeXZ + (z - startPos.z) * faceDataSizeX + (x - startPos.x)];

						if (face.blockData[RIGHT])
							GenerateFaceTriangles(mesh, RIGHT, face, x, sy + y, z, startPos, endPos);

						if (face.blockData[LEFT])
							GenerateFaceTriangles(mesh, LEFT, face, x, sy + y, z, startPos, endPos);
					}
				}

				// Top/Bottom face in YZX order
				if (directions & ((1 << TOP) | (1 << BOTTOM)))
				{
					for (uint8_t y = 0; y < SECTION_SIZE; y++)
					for (uint8_t z = startPos.z; z < endPos.z; z++)
					for (uint8_t x = startPos.x; x < endPos.x; x++)
					{
						const FaceData& face = faceData[y * faceDataSizeXZ + (z - startPos.z) * faceDataSizeX + (x - startPos.x)];

						if (face.blockData[TOP])
							GenerateFaceTriangles(mesh, TOP, face, x, sy + y, z, startPos, endPos);

						if (face.blockData[BOTTOM])
							GenerateFaceTriangles(mesh, BOTTOM, face, x, sy + y, z, startPos, endPos);
					}
				}

				// Front/Back face in ZYX order
				if (directions & ((1 << FRONT) | (1 << BACK)))
				{
					for (uint8_t z = startPos.z; z < endPos.z; z++)
					for (uint8_t y = 0; y < SECTION_SIZE; y++)
					for (uint8_t x = startPos.x; x < endPos.x; x++)
					{
						const FaceData& face = faceData[y * faceDataSizeXZ + (z - startPos.z) * faceDataSizeX + (x - startPos.x)];

						if (face.blockData[FRONT])
							GenerateFaceTriangles(mesh, FRONT, face, x, sy + y, z, startPos, endPos);

						if (face.blockData[BACK])
							GenerateFaceTriangles(mesh, BACK, face, x, sy + y, z, startPos, endPos);
					}
				}
			}

			// Release views before another chunk reuses the worker storage
			for (FaceData*& data : mesh.faceData)
				data = nullptr;

			for (VertexData*& data : mesh.vertexData)
				data = nullptr;
		}
	}

	void Chunk::GenerateFaceTriangles(Mesh& mesh, Chunk::FaceDirection dir, const FaceData& face, uint16_t x, uint16_t y, uint16_t z, const WorldVec& startPos, const WorldVec& endPos)
	{
		const uint32_t& blockData = face.blockData[dir];

		// Make face as big as possible by merging with identical data
		WorldVec faceOffset = { 0, 0, 0 };
		WorldVec pos = { x, y, z };

		// Returns whether the current data is equal to another face at a given position in the chunk
		auto faceMatch = [&](const WorldVec& pos, uint32_t*& outBlockData)
		{
			if (pos.x < startPos.x || pos.y < 0 || pos.z < startPos.z ||
				pos.x == endPos.x || pos.y >= CHUNK_HEIGHT_SIZE || pos.z == endPos.z)
				return false;

			uint8_t sectionIndex = pos.y / SECTION_SIZE;
			if (!mesh.faceData[sectionIndex]) // No faces in target section
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
			uint32_t* offsetBlockData = nullptr;
			if (!faceMatch(pos + offset, offsetBlockData))
				break;
		
			*offsetBlockData = 0; // Erase data of face
			faceOffset = offset;
		}
		
		// Resize in second direction
		uint32_t* offsetBlockData[SECTION_SIZE];
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

		// Reserve a full quad with geometric growth, without clearing append-only storage
		if (mesh.vertices.heap.Size() < mesh.vertices.Size() + 4)
			mesh.vertices.heap.Alloc(std::max(mesh.vertices.Size() + 4, std::max(IntType(256), mesh.vertices.heap.Size() * 2)), false);

		if (mesh.indices.heap.Size() < mesh.indices.Size() + 6)
			mesh.indices.heap.Alloc(std::max(mesh.indices.Size() + 6, std::max(IntType(384), mesh.indices.heap.Size() * 2)), false);

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
		uint32_t* indices = mesh.indices.heap.data + mesh.indices.size;
		indices[0] = index[0];
		indices[1] = index[1];
		indices[2] = index[2];
		indices[3] = index[2];
		indices[4] = index[3];
		indices[5] = index[0];
		mesh.indices.size += 6;
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
