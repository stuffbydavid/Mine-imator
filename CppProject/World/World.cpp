#include "World.hpp"

#include "AppHandler.hpp"
#include "Asset/Script.hpp"
#include "Asset/Sprite.hpp"
#include "GZIP.hpp"
#include "NBT.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/Texture.hpp"

#include <QDirIterator>

namespace CppProject
{
	QDir World::currentRegionsDir;
	Preview* World::preview = nullptr;
	QVector<Region*> World::regions;
	QHash<QString, SaveInfo> World::saves;
	QHash<StringType, BoolType> World::mcBlockIdWaterloggedMap, World::filteredMcBlockIdWaterloggedMap;
	BoolType World::waterRemoved = false;

	void World::Init()
	{
		// Create texture
		BlockStyle::previewImage = QImage(PREVIEW_TEXTURE_SIZE, PREVIEW_TEXTURE_SIZE, QImage::Format_RGBA8888);
		BlockStyle::previewImage.fill(Qt::transparent);

		// Add air style
		BlockStyle::Create(0, 0.0);
		BlockStyle::airStyle = BlockStyle::blockStyles[0];

		// Find biomes
		Sprite* colorMapGrass = FindSprite(ObjType(obj_resource, global::mc_res)->colormap_grass_texture);
		Sprite* colorMapFoliage = FindSprite(ObjType(obj_resource, global::mc_res)->colormap_foliage_texture);
		QVector<IntType> biomes = Object::GetAll(ID_obj_biome);
		for (IntType id : biomes)
		{
			obj_biome* biome = ObjType(obj_biome, id);
			StringType name = biome->name.ToStr();
			if (name == "normal" || name == "custom")
				continue;

			IntType grassColor, foliageColor;
			if (biome->hardcoded)
			{
				grassColor = biome->color_grass;
				foliageColor = biome->color_foliage;
			}
			else
			{
				ArrType point = biome->txy;
				grassColor = GFX->QColorToInt(colorMapGrass->GetPixel(0, { (int)point[0], (int)point[1] }));
				foliageColor = GFX->QColorToInt(colorMapFoliage->GetPixel(0, { (int)point[0], (int)point[1] }));
			}

			Preview::mcBiomeIdIndexMap[name] = Preview::biomeTints.size();
			Preview::biomeTints.append({ grassColor, foliageColor, biome->color_water });
		}

		// Iterate Minecraft IDs and make id->texture position map
		QMapIterator<VarType, Map::MapValue> it(DsMap(ObjType(obj_minecraft_assets, global::mc_assets)->block_id_map).map);
		while (it.hasNext())
		{
			it.next();
			StringType mcId = it.key();
			StringType mcIdNoMc = mcId.Replaced("minecraft:", "");

			// Find block and state
			obj_block* block = ObjType(obj_block, it.value().value);
			mcBlockIdWaterloggedMap[mcIdNoMc] = block->waterlogged;

			uint16_t stateId = 0;
			if (block->id_state_vars_map != null_)
			{
				VarType state = DsMap(block->id_state_vars_map)[mcId];
				if (state.IsArray())
					stateId = block_get_state_id(block->id, state);
			}

			VarType modelObj = block->state_id_model_obj[stateId];
			if (modelObj.IsArray())
				modelObj = modelObj[0];

			// Find first model of block + state combination and add to texture
			uint16_t styleIndex = 0;
			if (obj_block_load_variant* modelFile = ObjTypeOpt(obj_block_load_variant, modelObj))
			{
				if (modelFile->model_amount > 0)
				{
					obj_block_render_model* model = ObjType(obj_block_render_model, modelFile->model[0]);

					BlockStyle::TintType tint = BlockStyle::NONE;
					if (model->preview_tint == "grass")
						tint = BlockStyle::GRASS;
					else if (model->preview_tint == "foliage")
						tint = BlockStyle::FOLIAGE;
					else if (model->preview_tint == "water")
						tint = BlockStyle::WATER;

					styleIndex = BlockStyle::Create(
						model->preview_color_zp, model->preview_alpha_zp,
						model->preview_color_yp, model->preview_alpha_yp,
						tint
					);
				}
			}

			if (mcIdNoMc == "bedrock")
				BlockStyle::bedrockStyle = BlockStyle::blockStyles[styleIndex];

			Preview::mcBlockIdStyleIndexMap[mcIdNoMc] = styleIndex;
		}

		// Water/Lava
		Preview::mcBlockIdStyleIndexMap["water"] =
		Preview::mcBlockIdStyleIndexMap["flowing_water"] = BlockStyle::Create(make_color_rgb(50, 60, 255), 0.4, -1, 1.0, BlockStyle::WATER);
		Preview::mcBlockIdStyleIndexMap["lava"] =
		Preview::mcBlockIdStyleIndexMap["flowing_lava"] = BlockStyle::Create(make_color_rgb(255, 100, 0), 1.0, -1, 1.0, BlockStyle::NONE, 26);


		// Preview texture
		BlockStyle::previewTexture = new Texture(BlockStyle::previewImage);

		// Create preview viewport handler
		preview = new Preview;

		// Allocate block object lookup tables for builder
		const Map& blockIdMap = DsMap(ObjType(obj_minecraft_assets, global::mc_assets)->block_id_map);
		QMapIterator<VarType, Map::MapValue> mapIt(blockIdMap.map);
		while (mapIt.hasNext())
		{
			mapIt.next();
			StringType mcId = mapIt.key();
			StringType mcIdNoMc = mcId.Replaced("minecraft:", "");

			obj_block* block = ObjType(obj_block, mapIt.value().value);
			Builder::mcBlockIdObjMap[mcIdNoMc] = block;

			if (block->id_state_vars_map != null_) // Store id specific vars as array
			{
				VarType idVars = DsMap(block->id_state_vars_map)[mcId];
				if (idVars.IsArray())
					Builder::mcBlockIdStateVarsMap[mcIdNoMc] = idVars.Arr();
			}
		}

		Builder::blocks.Alloc(global::block_objs.Size());
		Builder::blocks[0] = nullptr;
		for (int b = 1; b < global::block_objs.Size(); b++)
			Builder::blocks[b] = ObjType(obj_block, global::block_objs.Value(b));

		// Allocate render model object lookup table for builder
		Builder::renderModels.Alloc(global::block_rendermodels.Size());
		Builder::renderModels[0] = nullptr;
		for (int m = 1; m < global::block_rendermodels.Size(); m++)
			Builder::renderModels[m] = ObjType(obj_block_render_model, global::block_rendermodels.Value(m));

		// Grass path support
		Builder::mcBlockIdObjMap["grass_path"] = Builder::mcBlockIdObjMap["dirt_path"];
		Preview::mcBlockIdStyleIndexMap["grass_path"] = Preview::mcBlockIdStyleIndexMap["dirt_path"];

		// Apply current filter
		ApplyFilter();

		// Start region loading
		Region::loader = new RegionLoader;
	}

	void World::Open(QDir regionsDir)
	{
		DEBUG("Open world " + regionsDir.path());

		Close();

		currentRegionsDir = regionsDir;

		// Add new regions
		QDirIterator it(regionsDir);
		Timer tmr;
		while (it.hasNext())
		{
			QString filename = it.next();
			if (QFile(filename).size())
				World::regions.append(new Region(filename));
		}

		StringType::qThreadActive = true;
	}

	void World::Close()
	{
		// Clear old regions
		for (Region* region : World::regions)
			delete region;
		World::regions.clear();

		currentRegionsDir = QDir();
		StringType::qThreadActive = false;
	}

	void World::GenerateBuilderSections(const WorldBox& box)
	{
		if (!box.active) // No selection
			return;

		// Allocate builder sections (Y and Z is flipped)
		obj_builder* builder = ObjType(obj_builder, global::mc_builder);
		VecType size = box.GetSize();
		builder->build_size_x = size.x;
		builder->build_size_y = size.z;
		builder->build_size_z = size.y;
		Builder::offset = { box.start.x & SECTION_SIZEM1, box.start.z & SECTION_SIZEM1, box.start.y & SECTION_SIZEM1 };
		builder_start(Scope<obj_builder>(builder));

		// Load regions within box
		debug_timer_start();
		builder->sch_timeline_amount = 0;
		builder->builder_scenery_legacy = false;

		for (Region* region : regions)
		{
			region->Load(box);
			if (region->legacy)
				builder->builder_scenery_legacy = true;
			builder->sch_timeline_amount += region->numTimelines;
		}
		debug_timer_stop("Load world sections");

		// Add missing sections with only air
		for (IntType i = 0; i < Builder::sections.Size(); i++)
		{
			if (!Builder::sections[i])
			{
				Builder::sections[i] = new Section({ 0, 0, 0 }, { SECTION_SIZE, SECTION_SIZE, SECTION_SIZE });
				Builder::sections[i]->AddBuilderState({ 0, 0, false });
			}
		}

		// Process block entities
		builder_spawn_threads(Scope<obj_builder>(builder->id), 1);
		withOne(obj_builder_thread, DsList(builder->thread_list).Value(0), noone)
		{
			for (Region* region : regions)
			{
				if (region->loadStatus == Region::UNLOADED)
					continue;

				for (Chunk* chunk : region->chunks)
				{
					if (!chunk)
						continue;

					for (BlockEntity& blockEntity : chunk->blockEntities)
					{
						self->build_pos_x = blockEntity.pos.x;
						self->build_pos_y = blockEntity.pos.z; // Z and Y are flipped
						self->build_pos_z = blockEntity.pos.y;
						self->build_pos = self->build_pos_z * self->build_size_xy + self->build_pos_y * self->build_size_x + self->build_pos_x;
						self->block_current = builder_get_block(self, self->build_pos_x, self->build_pos_y, self->build_pos_z);
						self->block_state_id_current = builder_get_state_id(self, self->build_pos_x, self->build_pos_y, self->build_pos_z);
						script_execute(self, { blockEntity.script->id, blockEntity.map->id });
						delete blockEntity.map;
					}
				}
			}
		}
		builder_combine_threads(Scope<obj_builder>(builder->id));
	}

	BoolType World::AddSave(QString dir)
	{
		StringType levelsDat = dir + "/level.dat";
		if (!QFile(levelsDat).exists())
			return false;

		QByteArray bytesRaw;
		Gzip::Decompress(levelsDat, bytesRaw);

		// Get save info
		SaveInfo info;
		try
		{
			NbtStream stream(bytesRaw, QHash<NbtType, QVector<StringType>>({
				{ TAG_INT, { "version", "Id", "SpawnX", "SpawnY", "SpawnZ", "Dimension" }},
				{ TAG_STRING, { "LevelName", "Dimension" }},
				{ TAG_LIST, { "Pos", "Rotation" }},
				{ TAG_COMPOUND, { "Data", "Player" }}
			}));
			NbtCompound saveData(stream);
			if (!saveData.HasKey("Data"))
				return false;

			NbtCompound* data = saveData.Compound("Data");
			if (!data->HasKey("LevelName"))
				return false;

			info.name = data->String("LevelName");
			QChar formatSymbol(167);
			if (info.name.contains(formatSymbol)) // Remove formatting codes in name
			{
				QString newName = "";
				for (int i = 0; i < info.name.size(); i++)
				{
					if (info.name[i] == formatSymbol)
						i++;
					else
						newName += info.name[i];
				}
				info.name = newName;
			}
			
			info.spawnPos = { (RealType)data->Int("SpawnX"), (RealType)data->Int("SpawnY"), (RealType)data->Int("SpawnZ") };
			info.playerDim = "overworld";

			// Parse single player
			if (info.hasPlayer = data->HasKey("Player"))
			{
				NbtCompound* player = data->Compound("Player");
				QVector<NbtDouble*> playerPos = player->List<NbtType::TAG_DOUBLE, NbtDouble>("Pos");
				QVector<NbtFloat*> playerRot = player->List<NbtType::TAG_FLOAT, NbtFloat>("Rotation");
				info.playerPos = { (RealType)playerPos[0]->value, (RealType)playerPos[1]->value, (RealType)playerPos[2]->value };
				info.playerRot = { -(RealType)playerRot[1]->value, mod_fix(180 - (RealType)playerRot[0]->value, 360), 0.0 };

				if (data->Int("version") >= 19133) // Offset by head position in new worlds
					info.playerPos.y += 24.0 / 16.0;

				if (player->GetType("Dimension") == TAG_STRING) // String dimension
					info.playerDim = player->String("Dimension").Replaced("minecraft:", "").Replaced("the_", "");

				else // Integer dimension
					switch (player->Int("Dimension"))
					{
						case 0: info.playerDim = "overworld"; break;
						case 1: info.playerDim = "the_end"; break;
						case -1: info.playerDim = "nether"; break;
					}
			}
		}
		catch (const QString& str)
		{
			WARNING("Error loading " + levelsDat.QStr() + ": " + str);
			return false;
		}

		// Find dimensions
		StringType filter = "*.mca";
		QDir overworldDir(dir + "/region", filter, QDir::Name | QDir::IgnoreCase, QDir::Files | QDir::NoDotAndDotDot);
		if (overworldDir.isEmpty()) // Pre-anvil
		{
			filter = "*.mcr";
			overworldDir.setNameFilters({ filter });
		}
		QDir netherDir(dir + "/DIM-1/region", filter);
		QDir endDir(dir + "/DIM1/region", filter);

		info.dimDir["overworld"] = overworldDir;
		if (netherDir.exists() && !netherDir.isEmpty())
			info.dimDir["nether"] = netherDir;
		if (endDir.exists() && !endDir.isEmpty())
			info.dimDir["end"] = endDir;

		World::saves[dir] = info;
		return true;
	}

	BoolType World::ApplyFilter()
	{
		QHash<StringType, uint16_t> newFilteredPreviewMap;
		QHash<StringType, obj_block*> newFilteredBuilderMap;
		BoolType filterEnabled = global::_app->setting_world_import_filter_enabled;
		FilterMode filterMode = (FilterMode)global::_app->setting_world_import_filter_mode.ToInt();

		if (filterEnabled)
		{
			waterRemoved = (filterMode == KEEP); // Water removed by default in keep mode

			if (filterMode == REMOVE) // Copy unfiltered maps
			{
				newFilteredPreviewMap = Preview::mcBlockIdStyleIndexMap;
				newFilteredBuilderMap = Builder::mcBlockIdObjMap;
			}

			// Iterate block list
			const List& filterList = DsList(global::_app->setting_world_import_filter_list);
			const List& blockList = DsList(ObjType(obj_minecraft_assets, global::mc_assets)->block_list);
			for (const List::ListValue& val : filterList.vec)
			{
				obj_block* block = ObjType(obj_block, blockList.Value(val.value));
				for (IntType i = 0; i < block->mc_ids.Size(); i++) // Find all Minecraft IDs in this block
				{
					StringType mcId = block->mc_ids.Value(i);
					if (mcId == "water")
						World::waterRemoved = (filterMode == REMOVE);

					if (filterMode == REMOVE)
					{
						newFilteredPreviewMap.remove(mcId);
						newFilteredBuilderMap.remove(mcId);
					}
					else if (filterMode == KEEP)
					{
						newFilteredPreviewMap[mcId] = Preview::mcBlockIdStyleIndexMap.value(mcId);
						newFilteredBuilderMap[mcId] = Builder::mcBlockIdObjMap.value(mcId);
					}
				}
			}
		}
		else // Copy unfiltered map
		{
			World::waterRemoved = false;
			newFilteredPreviewMap = Preview::mcBlockIdStyleIndexMap;
			newFilteredBuilderMap = Builder::mcBlockIdObjMap;
		}

		// Check if updated
		BoolType changed = false;
		if (Preview::filteredMcBlockIdStyleIndexMap != newFilteredPreviewMap)
		{
			Preview::filteredMcBlockIdStyleIndexMap = newFilteredPreviewMap;
			changed = true;
		}
		if (Builder::filteredMcBlockIdObjMap != newFilteredBuilderMap)
		{
			Builder::filteredMcBlockIdObjMap = newFilteredBuilderMap;
			changed = true;
		}

		// Update waterlogged map (empty if water is removed)
		if (World::waterRemoved)
			filteredMcBlockIdWaterloggedMap.clear();
		else
			filteredMcBlockIdWaterloggedMap = mcBlockIdWaterloggedMap;

		// Legacy id mapping
		for (IntType b = 0; b < 256; b++)
		for (IntType d = 0; d < 16; d++)
		{
			VarType mcId = global::legacy_block_mc_id[b][d];
			Preview::filteredMcLegacyBlockIdStyleIndex[b][d] = Preview::filteredMcBlockIdStyleIndexMap.value(mcId, 0);
			Builder::filteredMcLegacyBlockIdObj[b][d] = Builder::filteredMcBlockIdObjMap.value(mcId, nullptr);
		}

		return changed;
	}

	WorldVec WorldVec::operator+(const WorldVec& vec) const
	{
		return { x + vec.x, y + vec.y, z + vec.z };
	}

	WorldVec WorldVec::operator-(const WorldVec& vec) const
	{
		return { x - vec.x, y - vec.y, z - vec.z };
	}

	WorldVec WorldVec::operator*(const WorldVec& vec) const
	{
		return { x * vec.x, y * vec.y, z * vec.z };
	}

	WorldVec WorldVec::operator+(IntType in) const
	{
		return { x + in, y + in, z + in };
	}

	WorldVec WorldVec::operator-(IntType in) const
	{
		return { x - in, y - in, z - in };
	}

	WorldVec WorldVec::operator*(IntType in) const
	{
		return { x * in, y * in, z * in };
	}

	WorldVec::operator VecType() const
	{
		return { (RealType)x, (RealType)y, (RealType)z };
	}
}
