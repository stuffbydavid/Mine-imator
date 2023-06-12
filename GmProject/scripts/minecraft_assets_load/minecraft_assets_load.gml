/// minecraft_assets_load()
/// @desc Loads assets from an archive.

function minecraft_assets_load()
{
	with (mc_assets)
	{
		switch (load_assets_stage)
		{
			// Unzip archive
			case "unzip":
			{
				if (current_step < 5)
					break
				
				// Check already unzipped
				var exists = directory_exists_lib(load_assets_dir + mc_assets_directory);
				if (array_length(file_find(load_assets_dir + mc_character_directory, ".mimodel")) = 0 ||
					array_length(file_find(load_assets_dir + mc_block_directory, ".json")) = 0 ||
					array_length(file_find(load_assets_dir + mc_textures_directory + "block/", ".png")) = 0)
					exists = false
				
				if (!exists)
				{
					debug_timer_start()
					if (!unzip(load_assets_zip_file, load_assets_dir))
					{
						log("Could not unzip archive")
						directory_delete_lib(load_assets_dir)
						access_error()
						return false
					}
					debug_timer_stop("Unzip archive")
				}
				else
					log("Archive already unzipped, re-using", load_assets_dir + mc_assets_directory)
				
				load_assets_stage = "biomes"
				load_assets_progress = 0.3
				file_copy_temp = false
				break
			}
			
			// Load biomes
			case "biomes":
			{
				with (mc_res)
					minecraft_assets_load_biomes(biome_list, load_assets_map[?"biomes"]);
				
				app.background_biome = biome_list[|2].name
				app.background_foliage_color = c_plains_biome_foliage
				app.background_grass_color = c_plains_biome_grass
				app.background_water_color = c_plains_biome_water
				
				app.background_leaves_oak_color = c_plains_biome_foliage
				app.background_leaves_spruce_color = c_plains_biome_foliage_2
				app.background_leaves_birch_color = c_plains_biome_foliage_2
				app.background_leaves_jungle_color = c_plains_biome_foliage
				app.background_leaves_acacia_color = c_plains_biome_foliage
				app.background_leaves_dark_oak_color = c_plains_biome_foliage
				app.background_leaves_mangrove_color = c_plains_biome_foliage
				
				load_assets_stage = "textures"
				load_assets_progress = 0.4
				break;
			}
			
			// Load textures
			case "textures":
			{
				// Model textures
				var modeltextureslist = load_assets_map[?"model_textures"];
				if (is_undefined(modeltextureslist))
				{
					log("No model textures found")
					return false
				}
				
				ds_list_copy(model_texture_list, modeltextureslist)
				
				// Block textures
				var blocktextureslist = load_assets_map[?"block_textures"];
				if (is_undefined(blocktextureslist))
				{
					log("No block textures found")
					return false
				}
				
				ds_list_copy(block_texture_list, blocktextureslist)
				
				// Animated block textures
				var blocktexturesanimatedlist = load_assets_map[?"block_textures_animated"];
				if (is_undefined(blocktexturesanimatedlist))
				{
					log("No animated block textures found")
					return false
				}
				
				ds_list_copy(block_texture_ani_list, blocktexturesanimatedlist)
				
				// Block texture colors
				var blocktexturescolorlist = load_assets_map[?"block_textures_color"];
				if (is_undefined(blocktexturescolorlist))
				{
					log("No block texture colors found")
					return false
				}
				
				ds_map_copy(block_texture_color_map, blocktexturescolorlist)
				
				// Convert from hex
				var key = ds_map_find_first(block_texture_color_map);
				while (!is_undefined(key))
				{
					if (string_char_at(block_texture_color_map[?key], 1) = "#")
						block_texture_color_map[?key] = hex_to_color(block_texture_color_map[?key])
					key = ds_map_find_next(block_texture_color_map, key)
				}
				
				// Block texture preview settings
				var blocktexturepreview = load_assets_map[?"block_textures_preview"];
				if (!is_undefined(blocktexturepreview))
					ds_map_copy(block_texture_preview_map, blocktexturepreview)
				
				// Item textures
				var itemtextureslist = load_assets_map[?"item_textures"];
				if (is_undefined(itemtextureslist))
				{
					log("No item textures found")
					return false
				}
				
				ds_list_copy(item_texture_list, itemtextureslist)
				
				// Particle textures
				var particletextureslist = load_assets_map[?"particle_textures"];
				if (is_undefined(particletextureslist))
				{
					log("No particle textures found")
					return false
				}
				
				if (is_undefined(load_assets_map[?"particles"]))
				{
					log("No particle list found")
					return false
				}
				
				ds_list_copy(particle_texture_list, particletextureslist)
				
				// Create sheets and texture depth
				with (mc_res)
				{
					res_load_pack_model_textures()
					res_load_pack_block_textures()
					
					res_load_pack_item_textures("diffuse", "")
					item_sheet_texture_material = sprite_duplicate(spr_default_material)
					item_sheet_tex_normal = sprite_duplicate(spr_default_normal)
					
					minecraft_assets_load_particles(load_assets_map[?"particles"])
					res_load_pack_particle_textures()
					
					res_load_pack_misc()
					res_update_colors(biome_list[|2].name)
				}
				
				load_assets_stage = "misc"
				load_assets_progress = 0.45
				break
			}
			
			// Misc. assets
			case "misc":
			{	
				// Pattern designs
				if (is_undefined(load_assets_map[?"patterns"]))
				{
					log("No pattern designs list found")
					return false
				}
				
				var patternlist = load_assets_map[?"patterns"];
				
				for (var i = 0; i < ds_list_size(patternlist); i++)
				{
					var pattern = patternlist[|i];
					ds_list_add(minecraft_pattern_list, pattern[|0])
					ds_list_add(minecraft_pattern_short_list, pattern[|1])
				}
				
				load_assets_stage = "models"
				load_assets_progress = 0.5
				break;
			}
			
			// Load models
			case "models":
			{
				// Characters
				var characterslist = load_assets_map[?"characters"];
				if (is_undefined(characterslist))
				{
					log("No character list found")
					return false
				}
				
				debug_timer_start()
				for (var i = 0; i < ds_list_size(characterslist); i++)
				{
					var model = model_load(characterslist[|i], load_assets_dir + mc_character_directory);
					if (!model) // Something went wrong!
					{
						log("Could not load model")
						continue
					}
					
					model_name_map[?model.name] = model
					
					ds_list_add(char_list, model)
				}
				debug_timer_stop("Load characters")
				
				// Special blocks
				var specialblockslist = load_assets_map[?"special_blocks"];
				if (is_undefined(specialblockslist))
				{
					log("No special block list found")
					return false
				}
				
				debug_timer_start()
				for (var i = 0; i < ds_list_size(specialblockslist); i++)
				{
					var model = model_load(specialblockslist[|i], load_assets_dir + mc_special_block_directory);
					if (!model) // Something went wrong!
					{
						log("Could not load model")
						continue
					}
					
					model_name_map[?model.name] = model
					
					ds_list_add(special_block_list, model)
				}
				debug_timer_stop("Load special blocks")
				
				debug_timer_start()
				load_assets_stage = "blocks"
				load_assets_progress = 0.6
				break
			}
			
			// Load blocks
			case "blocks":
			{
				// Blocks
				var blockslist = load_assets_map[?"blocks"];
				if (is_undefined(blockslist))
				{
					log("No block list found")
					return false
				}
				
				repeat (20)
				{
					if (load_assets_block_index = ds_list_size(blockslist))
					{
						load_assets_stage = "done"
						break
					}
					
					var blockmap, block;
					blockmap = blockslist[|load_assets_block_index]
					block = block_load(blockmap, load_assets_type_map)
					if (!block)
					{
						log("Could not load block")
						continue
					}
					
					// Save name in load_assets_map
					block_name_map[?block.name] = block
					
					ds_list_add(block_list, block)
					
					load_assets_block_index++
				}
				
				load_assets_progress = 0.6 + 0.4 * (load_assets_block_index / ds_list_size(blockslist))
				
				if (dev_mode_skip_blocks)
					load_assets_stage = "done"
				if (load_assets_stage = "done")
				{
					// Flowing Water/Lava
					block_name_map[?"flowing_water"] = block_name_map[?"water"]
					block_name_map[?"flowing_lava"] = block_name_map[?"lava"]
					block_liquid_slot_map[?"water"] = ds_list_find_index(block_texture_ani_list, "block/water_still")
					block_liquid_slot_map[?"lava"] = ds_list_find_index(block_texture_ani_list, "block/lava_still")
					block_liquid_slot_map[?"flowing_water"] = ds_list_find_index(block_texture_ani_list, "block/water_flow")
					block_liquid_slot_map[?"flowing_lava"] = ds_list_find_index(block_texture_ani_list, "block/lava_flow")
					
					// Grass paths renamed to dirt path in 1.17
					if (!dev_mode_skip_blocks)
						block_id_map[?"minecraft:grass_path"] = block_id_map[?"minecraft:dirt_path"]
					
					// Legacy block ID mapping
					var key = ds_map_find_first(legacy_block_id);
					while (!is_undefined(key))
					{
						var curid, curmap;
						curid = string_get_real(key)
						curmap = ds_map_find_value(legacy_block_id, key)
						legacy_block_set[curid] = true
						
						// Look for block object from ID
						var newid, newidnomc, block, statevars;
						newid = curmap[?"id"]
						if (!is_undefined(newid))
							newidnomc = string_replace(curmap[?"id"], "minecraft:", "")
						else
							newidnomc = ""
						block = null
						statevars = null
						if (is_string(newid) && !is_undefined(block_id_map[?newid]))
						{
							block = block_id_map[?newid]
							if (block.id_state_vars_map != null && !is_undefined(block.id_state_vars_map[?newid]))
								statevars = block.id_state_vars_map[?newid]
						}
						
						for (var d = 0; d < 16; d++)
						{
							legacy_block_mc_id[curid, d] = newidnomc
							legacy_block_obj[curid, d] = block
							if (statevars != null)
								legacy_block_state_vars[curid, d] = array_copy_1d(statevars)
							else
								legacy_block_state_vars[curid, d] = null
							legacy_block_state_id[curid, d] = 0
						}
						
						// Look for block states
						if (!is_undefined(curmap[?"data"]))
							minecraft_assets_load_legacy_block_data(curid, curmap[?"data"], 0, 1)
						
						// Get block-specific state IDs
						for (var d = 0; d < 16; d++)
							if (legacy_block_obj[curid, d] != null && legacy_block_state_vars[curid, d] != null)
								legacy_block_state_id[curid, d] = block_get_state_id(legacy_block_obj[curid, d], legacy_block_state_vars[curid, d])
						
						key = ds_map_find_next(legacy_block_id, key)
					}
					
					debug_timer_stop("Load blocks")
					
					// Clean up loaded model file objects
					key = ds_map_find_first(load_assets_model_file_map)
					while (!is_undefined(key))
					{
						with (load_assets_model_file_map[?key])
							instance_destroy()
						key = ds_map_find_next(load_assets_model_file_map, key)
					}
					
					// Dev mode: Look for newly added block states and model files
					if (dev_mode_debug_unused)
					{
						// Blockstates
						var filesarr = file_find(load_assets_dir + mc_blockstates_directory, ".json");
						var unusedlist = ds_list_create()
						
						for (var f = 0; f < array_length(filesarr); f++)
							if (is_undefined(load_assets_state_file_map[?filename_name(filesarr[f])]))
								ds_list_add(unusedlist, filesarr[f])
						
						if (ds_list_size(unusedlist) > 0)
						{
							ds_list_sort(unusedlist, true)
							var str = "The following blockstates were unused:\n";
							for (var i = 0; i < ds_list_size(unusedlist); i++)
								str += "  " + filename_name(unusedlist[|i]) + "\n"
							log(str)
						}
						
						// Block models
						filesarr = file_find(load_assets_dir + mc_models_directory + "block/", ".json");
						ds_list_clear(unusedlist)
						
						for (var f = 0; f < array_length(filesarr); f++)
							if (is_undefined(load_assets_model_file_map[?filename_name(filesarr[f])]))
								ds_list_add(unusedlist, filesarr[f])
						
						if (ds_list_size(unusedlist) > 0)
						{
							ds_list_sort(unusedlist, true)
							var str = "The following block models were unused:\n";
							for (var i = 0; i < ds_list_size(unusedlist); i++)
								str += "  " + filename_name(unusedlist[|i]) + "\n"
							log(str)
						}
						
						ds_list_destroy(unusedlist)
					}
					
					file_copy_temp = !is_cpp()
					
					ds_map_destroy(load_assets_state_file_map)
					ds_map_destroy(load_assets_model_file_map)
					ds_map_destroy(load_assets_map)
					ds_map_destroy(load_assets_type_map)
					buffer_delete(load_assets_block_preview_buffer)
					buffer_delete(load_assets_block_preview_ani_buffer)
					
					log("Loaded assets successfully")
					move_all_to_texture_page()
				}
				
				break
			}
		}
		
		return true
	}
}
