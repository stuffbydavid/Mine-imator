#include "World.hpp"
#include "NBT.hpp"

#include <bitset>

namespace CppProject
{
	uint8_t Section::blockFaceBaseLight[Chunk::FaceDirectionAmount] = {
		15, // Right
		18, // Left
		26, // Up
		10, // Down
		15, // Front
		12, // Back
	};

	Section::Section(Chunk* chunk, IntType y, const WorldBox& box) :
		chunk(chunk), region(chunk->region), chunkIndex(y - CHUNK_SECTION_MIN)
	{
		if (box.active) // Builder section
		{
			// Check section box with given selection
			WorldVec fullSize = WorldVec(SECTION_SIZE, SECTION_SIZE, SECTION_SIZE);
			WorldVec worldPos = region->pos + chunk->regionPos + WorldVec(0, chunkIndex * SECTION_SIZE, 0);
			if (!box.Intersects({ worldPos, worldPos + fullSize }))
				return;

			// Find dimensions of subsection within selection and allocate data
			WorldVec offsetStart = box.start - worldPos;
			WorldVec offsetEnd = (worldPos + fullSize) - box.end;
			blockStart = {
				std::max((int)offsetStart.x, 0),
				std::max((int)offsetStart.y, 0),
				std::max((int)offsetStart.z, 0)
			};
			blockEnd = fullSize - WorldVec(
				std::max((int)offsetEnd.x, 0),
				std::max((int)offsetEnd.y, 0),
				std::max((int)offsetEnd.z, 0)
			);

			InitBuilderData(worldPos, blockEnd - blockStart);

			// Add to builder list
			IntType sectionX, sectionY, sectionZ, sectionPos;
			WorldVec builderPos = worldPos - (box.start - WorldVec(Builder::offset.x, Builder::offset.z, Builder::offset.y));
			sectionX = builderPos.x >> 4;
			sectionY = builderPos.z >> 4;
			sectionZ = builderPos.y >> 4;
			sectionPos = sectionZ * Builder::sectionsXY + sectionY * Builder::sectionsDim.x + sectionX;
			Builder::sections[sectionPos] = this;
		}
		else // Preview section
		{
			dataType = PREVIEW;

			// Region position adjusted to positive Y
			preview.regionPos = { chunk->regionPos.x, chunk->regionPos.y + chunkIndex * SECTION_SIZE, chunk->regionPos.z };

			// Hide naturally occuring bedrock
			preview.hideBedrock = (y <= 0 || (region->dimName == "nether" && y == 7));

			// Enable section in GetPreviewState
			IntType regionIndex = (chunkIndex << 10) + (chunk->z << 5) + chunk->x;
			region->loadedSections[regionIndex] = this;
			preview.singleBlockStyle = BlockStyle::airStyle;
			preview.singleState = { false, false, false, 0 };

			blockStart = { 0, 0, 0 };
			blockEnd = { SECTION_SIZE, SECTION_SIZE, SECTION_SIZE };
		}
	}

	BoolType Section::Load(NbtCompound* nbt, Chunk::Format format)
	{
		if (dataType == NONE)
			return true;

		try
		{
			if (format > Chunk::JAVA_1_2)
			{
				if (dataType == PREVIEW) // Allocate data for preview and read light levels
				{
					preview.states.Alloc(SECTION_SIZE3);

					// Parse SkyLight
					if (nbt->HasKey("SkyLight"))
					{
						preview.hasLight = true;
						const Heap<int8_t>& skyLightArray = nbt->ByteArray("SkyLight");
						for (IntType i = 0; i < SECTION_SIZE3 / 2; i++)
						{
							IntType i2 = i << 1;
							preview.states[i2].value = skyLightArray.Value(i) & 15;
							preview.states[i2 + 1].value = (skyLightArray.Value(i) >> 4) & 15;
						}
					}

					// Parse BlockLight
					if (nbt->HasKey("BlockLight"))
					{
						preview.hasLight = true;
						const Heap<int8_t>& blockLightArray = nbt->ByteArray("BlockLight");
						for (IntType i = 0; i < SECTION_SIZE3 / 2; i++)
						{
							IntType i2 = i << 1;
							preview.states[i2].value += blockLightArray.Value(i) & 15;
							preview.states[i2 + 1].value += (blockLightArray.Value(i) >> 4) & 15;
						}
					}
				}

				// Find key names
				NbtCompound* blocksRoot = nbt;
				StringType blockPaletteName, blockDataName;
				if (format >= Chunk::Format::JAVA_1_18)
				{
					blockPaletteName = "palette";
					blockDataName = "data";

					if (nbt->HasKey("block_states"))
						blocksRoot = nbt->Compound("block_states");
					else
						return true;
				}
				else
				{
					blockPaletteName = "Palette";
					blockDataName = "BlockStates";
				}

				if (dataType == BUILDER) // Parse blocks for builder
					ParseBlockPaletteBuilder(blocksRoot, blockPaletteName, blockDataName, format);
				
				else // Parse blocks and biomes for preview
				{
					ParseBlockPalettePreview(blocksRoot, blockPaletteName, blockDataName, format);
					ParseBiomePalettePreview(nbt, format);
				}
			}

			// Legacy block arrays
			else
			{
				const Heap<int8_t>& blocksArray = nbt->ByteArray("Blocks");
				const Heap<int8_t>& dataArray = nbt->ByteArray("Data");
				const Heap<int8_t>& skyLightArray = nbt->ByteArray("SkyLight");
				const Heap<int8_t>& blockLightArray = nbt->ByteArray("BlockLight");

				// Pre Java 1.2 uses a single array for the chunk, so we add the section's y as offset
				IntType offset = 0;
				if (format == Chunk::Format::PRE_JAVA_1_2)
					offset = (chunkIndex + CHUNK_SECTION_MIN) * SECTION_SIZE;
				
				if (dataType == PREVIEW) // Allocate data for preview
				{
					preview.states.Alloc(SECTION_SIZE3);
					preview.blockStyleIndices.Alloc(SECTION_SIZE3);
					preview.hasLight = true;
					if (chunk->legacyBiomes.Size())
						preview.biomeIndices.Alloc(SECTION_SIZE3);
					else
						preview.singleBiomeIndex = Preview::mcBiomeIdIndexMap["plains"];
				}

				for (uint8_t x = blockStart.x; x < blockEnd.x; x++)
				for (uint8_t y = blockStart.y; y < blockEnd.y; y++)
				for (uint8_t z = blockStart.z; z < blockEnd.z; z++)
				{
					uint16_t blockIndex = (y << 8) + (z << 4) + x; // YZX order
					IntType arrayIndex;
					if (format == Chunk::Format::PRE_JAVA_1_2)
						arrayIndex = (x << 11) + (z << 7) + y + offset; // XZY order
					else
						arrayIndex = blockIndex; // YZX order

					IntType arrayIndexHalf = arrayIndex >> 1;
					uint8_t legacyId = blocksArray.Value(arrayIndex);
					uint8_t legacyData = dataArray.Value(arrayIndexHalf);

					// Parse data
					if (arrayIndex & 1) // Upper bits
						legacyData >>= 4;
					else // Lower bits
						legacyData &= 15;

					if (dataType == BUILDER) // Legacy id+data to block and state id
					{
						IntType builderIndex = (y - blockStart.y) * builder.sizeXY + (z - blockStart.z) * builder.size.x + (x - blockStart.x); // YZX order
						if (legacyId > 0 && global::legacy_block_set[legacyId]) // Non-air
						{
							if (obj_block* block = Builder::filteredMcLegacyBlockIdObj[legacyId][legacyData])
							{
								if (block->timeline)
									chunk->numTimelines++;
								builder.paletteIndices[builderIndex] = AddBuilderState({
									(uint16_t)block->block_id,
									(uint16_t)global::legacy_block_state_id[legacyId][legacyData].ToInt(),
									false
								});
							}
						}
						else // Air
							builder.paletteIndices[builderIndex] = AddBuilderState({ 0, 0, false });
					}
					else // Preview
					{
						// Parse light
						uint8_t skyLight = skyLightArray.Value(arrayIndexHalf);
						uint8_t blockLight = blockLightArray.Value(arrayIndexHalf);
						if (arrayIndex & 1) // Upper bits
						{
							skyLight >>= 4;
							blockLight >>= 4;
						}
						else // Lower bits
						{
							skyLight &= 15;
							blockLight &= 15;
						}

						// Set biome
						if (chunk->legacyBiomes.Size())
							preview.biomeIndices[blockIndex] = chunk->legacyBiomes[(z << 4) + x];

						// Parse block
						if (uint16_t blockStyleIndex = Preview::filteredMcLegacyBlockIdStyleIndex[legacyId][legacyData]) // Non-air
						{
							preview.blockStyleIndices[blockIndex] = blockStyleIndex;
							PreviewState& state = BlockStyle::blockPreviewStates[blockStyleIndex];
							BoolType solid = state.IsSolid();
							if (!solid)
								preview.hasTransparent = true;

							preview.states[blockIndex] = { true, solid, state.IsWaterlogged(), (uint8_t)(skyLight + blockLight) };
							preview.hasBlocks = true;
						}
						else // Air
							preview.states[blockIndex] = { false, false, false, (uint8_t)(skyLight + blockLight) };
					}
				}
			}
		}
		catch (const QString& ex)
		{
			WARNING("Error reading section at " + NumStr(chunk->x) + ", " + NumStr(chunk->z) + " [" + NumStr(chunkIndex) + "]: " + ex);
			return false;
		}

		// Check builder palette
		if (dataType == BUILDER)
		{
			if (builder.palette.Size()) // Trim memory
				builder.palette.Trim();
			else // Add air
				AddBuilderState({ 0, 0, false });
		}

		return true;
	}

	Section::~Section()
	{
		// Free array data
		for (IntType i = 0; i < builder.renderModelMultipartIds.Size(); i++)
			builder.renderModelMultipartIds[i].vec.Clear();
	}

	void Section::ParseBlockPalettePreview(NbtCompound* nbt, StringType paletteName, StringType dataName, Chunk::Format format)
	{
		struct PreviewPaletteEntry
		{
			uint16_t styleIndex;
			BoolType waterlogged;
		};
		FastVector<PreviewPaletteEntry> blockStylePalette;

		if (nbt->HasKey(paletteName))
		{
			QVector<NbtCompound*> paletteComp = nbt->List<TAG_COMPOUND, NbtCompound>(paletteName);
			blockStylePalette.Alloc(paletteComp.size());
			for (NbtCompound* entry : paletteComp)
			{
				// Parse ID
				StringType id = entry->String("Name");
				if (id != "air") // Non air
				{
					// Check waterlogged status
					BoolType waterlogged = false;
					if (entry->HasKey("Properties"))
					{
						NbtCompound* props = entry->Compound("Properties");
						if (props->HasKey("waterlogged") && !World::waterRemoved) // Waterlogged status
							waterlogged = (props->String("waterlogged") == "true");
					}

					preview.hasBlocks = true;
					blockStylePalette.Append({
						Preview::filteredMcBlockIdStyleIndexMap.value(id),
						(waterlogged || World::filteredMcBlockIdWaterloggedMap.value(id, false))
					});
				}
				else
					blockStylePalette.Append({ 0, false });
			}
		}

		if (nbt->HasKey(dataName)) // Has array
		{
			preview.blockStyleIndices.Alloc(SECTION_SIZE3);
			ParsePaletteIndices(nbt->LongArray(dataName), preview.blockStyleIndices, blockStylePalette.Size(), format, 4);

			// Set render states in section
			for (IntType b = 0; b < SECTION_SIZE3; b++)
			{
				uint16_t& index = preview.blockStyleIndices[b];
				const PreviewPaletteEntry& entry = blockStylePalette.Value(index);
				index = entry.styleIndex; // Palette index to style index

				if (index) // Non-air
				{
					PreviewState& state = BlockStyle::blockPreviewStates[index];
					BoolType solid = state.IsSolid();
					if (!solid || (entry.waterlogged && !state.IsBlock()))
						preview.hasTransparent = true;

					preview.states[b] = { true, solid, entry.waterlogged, preview.states.Value(b).value };
				}
				else // Air
				{
					if (entry.waterlogged)
						preview.hasTransparent = true;
					preview.states[b] = { false, false, entry.waterlogged, preview.states.Value(b).value };
				}
			}
		}
		else if (blockStylePalette.Size() == 1) // Single block fills section
		{
			const PreviewPaletteEntry& entry = blockStylePalette.Value(0);
			const PreviewState& state = BlockStyle::blockPreviewStates[entry.styleIndex];
			preview.singleBlockStyle = BlockStyle::blockStyles[entry.styleIndex];

			preview.singleState = {
				state.IsBlock(),
				state.IsSolid(),
				entry.waterlogged,
				(uint8_t)(state.GetLight() + preview.states.Value(0).value)
			};
			preview.hasTransparent = (!state.IsSolid() || (entry.waterlogged && !state.IsBlock()));
			preview.states.FreeData();
		}
		else if (blockStylePalette.Size() > 1)
			WARNING("Invalid section: No block array with multiple Palette entries");
	}

	void Section::ParseBiomePalettePreview(NbtCompound* nbt, Chunk::Format format)
	{
		if (nbt->HasKey("biomes"))
		{
			NbtCompound* biomesRoot = nbt->Compound("biomes");

			// Parse biome palette
			FastVector<uint16_t> biomePalette;
			QVector<NbtString*> paletteStrings = biomesRoot->List<TAG_STRING, NbtString>("palette");
			biomePalette.Alloc(paletteStrings.size());
			for (NbtString* entry : paletteStrings)
				biomePalette.Append(Preview::mcBiomeIdIndexMap.value(entry->value));

			if (biomesRoot->HasKey("data")) // Has array
			{
				preview.biomeIndices.Alloc(SECTION_SIZE3);
				ParsePaletteIndices(biomesRoot->LongArray("data"), preview.biomeIndices, biomePalette.Size(), format);
				for (IntType b = 0; b < SECTION_SIZE3; b++) // From palette index to biome id
					preview.biomeIndices[b] = biomePalette[preview.biomeIndices.Value(b)];

			}
			else if (biomePalette.Size()) // Single biome fills section
				preview.singleBiomeIndex = biomePalette[0];
		}
		else if (chunk->legacyBiomes.Size()) // Legacy biomes
		{
			preview.biomeIndices.Alloc(SECTION_SIZE3);
			for (uint8_t x = blockStart.x; x < blockEnd.x; x++)
			for (uint8_t y = blockStart.y; y < blockEnd.y; y++)
			for (uint8_t z = blockStart.z; z < blockEnd.z; z++)
			{
				uint16_t blockIndex = (y << 8) + (z << 4) + x; // YZX order
				preview.biomeIndices[blockIndex] = chunk->legacyBiomes[(z << 4) + x];
			}
		}
	}

	void Section::ParseBlockPaletteBuilder(NbtCompound* nbt, StringType paletteName, StringType dataName, Chunk::Format format)
	{
		QVector<BoolType> paletteHasTimeline;

		if (nbt->HasKey(paletteName))
		{
			// Convert NBT palette into builder palette
			QVector<NbtCompound*> paletteComp = nbt->List<TAG_COMPOUND, NbtCompound>(paletteName);
			builder.palette.Alloc(paletteComp.size());
			for (NbtCompound* entry : paletteComp)
			{
				StringType id = entry->String("Name");
				if (id != "air") // Non air
				{
					if (obj_block* block = Builder::filteredMcBlockIdObjMap.value(id, nullptr))
					{
						BuilderState state = { (uint16_t)block->block_id, 0, World::filteredMcBlockIdWaterloggedMap.value(id, false) };
						ArrType vars = Builder::mcBlockIdStateVarsMap.value(id, ArrType());

						if (entry->HasKey("Properties")) // Parse properties
						{
							NbtCompound* propertiesComp = entry->Compound("Properties");
							QHashIterator<StringType, NbtTag*> propIt(propertiesComp->value);
							while (propIt.hasNext())
							{
								propIt.next();
								if (propIt.value()->type == NbtType::TAG_STRING) // Insert into vars
								{
									StringType name = propIt.key();
									StringType value = ((NbtString*)propIt.value())->value;
									IntType i = 0;
									for (i = 0; i < vars.Size(); i += 2)
										if (vars.Value(i) == name)
											break;
									vars[i] = name;
									vars[i + 1] = value;

									// Waterlogged status
									if (name == "waterlogged" && !World::waterRemoved)
										state.waterlogged = (value == "true");
								}
							}
						}

						if (vars.Size()) // Array to id
							state.stateId = block_get_state_id(block->id, vars);

						builder.palette.Append(state);
						paletteHasTimeline.append(block->timeline);
						continue;
					}
				}

				// Air
				builder.palette.Append({ 0, 0, false });
				paletteHasTimeline.append(false);
			}
		}

		if (nbt->HasKey(dataName)) // Has array
		{
			if (builder.sizeTotal == SECTION_SIZE3) // Full section, read all indices
			{
				ParsePaletteIndices(nbt->LongArray(dataName), builder.paletteIndices, builder.palette.Size(), format, 4);

				// Count timelines
				if (!paletteHasTimeline.isEmpty())
					for (IntType b = 0; b < SECTION_SIZE3; b++)
						if (paletteHasTimeline.value(builder.paletteIndices.Value(b)))
							chunk->numTimelines++;
			}
			else // Convert
			{
				Heap<uint16_t> indices;
				indices.Alloc(SECTION_SIZE3);
				ParsePaletteIndices(nbt->LongArray(dataName), indices, builder.palette.Size(), format, 4);

				IntType b = 0;
				for (uint8_t y = blockStart.y; y < blockEnd.y; y++)
				for (uint8_t z = blockStart.z; z < blockEnd.z; z++)
				for (uint8_t x = blockStart.x; x < blockEnd.x; x++, b++) // ZYX order (Y and Z is flipped)
				{
					uint16_t blockIndex = (y << 8) + (z << 4) + x; // YZX order
					uint16_t paletteIndex = indices[blockIndex];
					builder.paletteIndices[b] = paletteIndex;

					// Count timelines
					if (!paletteHasTimeline.isEmpty() && paletteHasTimeline.value(paletteIndex))
						chunk->numTimelines++;
				}
			}
		}
		else if (builder.palette.Size() > 1)
			WARNING("Invalid section: No block array with multiple Palette entries");
	}

	void Section::GenerateFaces(Region::GenerateMode mode, const WorldVec& startPos, const WorldVec& endPos)
	{
		for (uint8_t x = startPos.x; x < endPos.x; x++)
		for (uint8_t y = 0; y < SECTION_SIZE; y++)
		for (uint8_t z = startPos.z; z < endPos.z; z++)
		{
			uint16_t blockIndex = (y << 8) + (z << 4) + x; // YZX order
			IntType faceDataIndex = y * chunk->faceDataSizeXZ + (z - startPos.z) * chunk->faceDataSizeX + (x - startPos.x);

			// Get current style
			BlockStyle* style;
			PreviewState state;
			if (preview.blockStyleIndices.Size())
			{
				style = BlockStyle::blockStyles.Value(preview.blockStyleIndices.Value(blockIndex));
				state = preview.states[blockIndex];
			}
			else
			{
				style = preview.singleBlockStyle;
				state = preview.singleState;
				if (x > 0 && y > 0 && z > 0 &&
					x < SECTION_SIZEM1 && y < SECTION_SIZEM1 && z < SECTION_SIZEM1) // No need to process inside section
					continue;
			}

			// Waterlogged air as water
			if (state.IsWaterlogged() && !state.IsBlock())
			{
				IntType waterIndex = Preview::filteredMcBlockIdStyleIndexMap.value("water", 0);
				style = BlockStyle::blockStyles.Value(waterIndex);
				state = BlockStyle::blockPreviewStates.Value(waterIndex);
			}

			// Skip air & bedrock
			else if (!state.IsBlock() || (preview.hideBedrock && style == BlockStyle::bedrockStyle))
				continue;

			// Get mesh
			Region::MeshType meshType = (state.IsSolid() ? Region::DEFAULT : Region::TRANSPARENT);
			Chunk::Mesh& mesh = chunk->meshes[meshType];
			Chunk::FaceData& faceData = mesh.faceData[chunkIndex][faceDataIndex];

			// Find biome
			uint16_t biomeIndex = 0;
			if (style->tint)
			{
				if (preview.biomeIndices.Size())
					biomeIndex = preview.biomeIndices.Value(blockIndex);
				else
					biomeIndex = preview.singleBiomeIndex;
			}

			// Look at adjacent block render states
			PreviewState states[Chunk::FaceDirectionAmount] =
			{
				GetPreviewState({ x + 1, y, z }, mode),
				GetPreviewState({ x - 1, y, z }, mode),
				GetPreviewState({ x, y + 1, z }, mode),
				GetPreviewState({ x, y - 1, z }, mode),
				GetPreviewState({ x, y, z + 1 }, mode),
				GetPreviewState({ x, y, z - 1 }, mode)
			};

			// Store non-colliding faces in chunk mesh
			for (uint8_t dir = 0; dir < Chunk::FaceDirectionAmount; dir++)
			{
				const PreviewState& dirState = states[dir];
				if (dirState.IsSolid()) // Skip colliding faces
					continue;

				if (!state.IsSolid() && ((dirState.IsBlock() && !dirState.IsSolid()) || dirState.IsWaterlogged()))  // Merge transparent blocks
					continue;

				// Store block data of face
				uint16_t texPos = (dir == Chunk::FaceDirection::TOP ? style->topPos : style->sidePos) + biomeIndex; 
				uint8_t light = std::max(state.GetLight(), blockFaceBaseLight[dir]) + std::min((dirState.GetLight()) * 2.5, 37.0);
				faceData.blockData[dir] = (texPos << 6) | light;
			}
		}
	}

	void Section::ParsePaletteIndices(const Heap<int64_t>& dataArray, Heap<uint16_t>& paletteIndices, IntType paletteSize, Chunk::Format format, IntType minBits)
	{
		IntType bitsPerBlock;
		if (format >= Chunk::Format::JAVA_1_13)
			bitsPerBlock = std::max(minBits, (IntType)std::ceil(std::log2f(paletteSize)));
		else
			bitsPerBlock = dataArray.Size() >> 6;

		IntType blockIndex = 0;
		IntType bitMask = std::pow(2, bitsPerBlock) - 1;
		IntType bitsRem = 0;
		uint64_t prevLong;

		for (IntType i = 0; i < dataArray.Size(); i++)
		{
			uint64_t curLong = dataArray.Value(i);
			IntType bitsLeft = 64;

			if (bitsRem) // Read remaining bits from last long
			{
				IntType paletteIndex = ((curLong << bitsRem) | prevLong) & bitMask;
			#if DEBUG_MODE
				if (paletteIndex >= paletteSize)
					FATAL("paletteIndex out of bounds");
			#endif
				if (blockIndex < SECTION_SIZE3)
					paletteIndices[blockIndex++] = paletteIndex;
				curLong >>= bitsPerBlock - bitsRem;
				bitsLeft -= bitsPerBlock - bitsRem;
			}

			while (bitsLeft >= bitsPerBlock) // Read current long
			{
				IntType paletteIndex = curLong & bitMask;
			#if DEBUG_MODE
				if (paletteIndex >= paletteSize)
					FATAL("paletteIndex out of bounds");
			#endif
				if (blockIndex < SECTION_SIZE3)
					paletteIndices[blockIndex++] = paletteIndex;
				curLong >>= bitsPerBlock;
				bitsLeft -= bitsPerBlock;
			}
			prevLong = curLong;
			bitsRem = (format >= Chunk::Format::JAVA_1_16) ? 0 : bitsLeft; // Discard remaining bits in 1.16+
		}
	}

	PreviewState Section::GetPreviewState(const WorldVec& pos, Region::GenerateMode mode)
	{
		// Position is outside section, check in region (slower)
		if (pos.x < 0 || pos.x > SECTION_SIZEM1 ||
			pos.y < 0 || pos.y > SECTION_SIZEM1 ||
			pos.z < 0 || pos.z > SECTION_SIZEM1)
			return region->GetPreviewState(preview.regionPos + pos, mode);

		uint16_t blockIndex = (pos.y << 8) + (pos.z << 4) + pos.x; // YZX order
		if (preview.blockStyleIndices.Size())
			return preview.states[blockIndex];
		else
			return preview.singleState;
	}

	void Section::InitBuilderData(const WorldVec& pos, const WorldVec& size)
	{
		dataType = BUILDER;

		// Convert Y up to Z up
		builder.pos = { pos.x, pos.z, pos.y };
		builder.size = { size.x, size.z, size.y };
		builder.sizeXY = builder.size.x * builder.size.y;
		builder.sizeTotal = builder.sizeXY * builder.size.z;

		builder.renderModelIds.Alloc(builder.sizeTotal); // Initialized with 0
		builder.paletteIndices.Alloc(builder.sizeTotal);
		builder.renderModelMultipartIds.Append(ArrType()); // Air
	}

	IntType Section::AddBuilderState(const BuilderState& state)
	{
		// Find existing block in palette
		int index;
		for (index = builder.palette.Size() - 1; index >= 0; index--)
		{
			const BuilderState& entry = builder.palette.Value(index);
			if (entry.blockId == state.blockId && entry.stateId == state.stateId && entry.waterlogged == state.waterlogged)
				break;
		}

		// Add new
		if (index < 0)
		{
			index = builder.palette.Size();
			builder.palette.Append(state);
		}

		return index;
	}

	IntType Section::GetBlockOffset(const WorldVec& pos)
	{
		WorldVec posOffset = (pos + Builder::offset);
		IntType blockX = (posOffset.x & SECTION_SIZEM1) - blockStart.x;
		IntType blockY = (posOffset.y & SECTION_SIZEM1) - blockStart.z; // blockStart use Y up
		IntType blockZ = (posOffset.z & SECTION_SIZEM1) - blockStart.y;
		return blockZ * builder.sizeXY + blockY * builder.size.x + blockX;
	}

	BuilderState& Section::GetBuilderState(const WorldVec& pos)
	{
		if (builder.palette.Size() == 1)
			return builder.palette[0];

		IntType offset = GetBlockOffset(pos);
		return builder.palette[builder.paletteIndices[offset]];
	}

	int16_t& Section::GetRenderModel(const WorldVec& pos)
	{
		IntType offset = GetBlockOffset(pos);
		return builder.renderModelIds[offset];
	}
}
