/// minecraft_assets_load()
/// @arg version
/// @desc Loads assets from an archive.

#macro dev_mode_name_translation_message " is not defined in the translation, the key will be formatted"

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
			if (array_length_1d(file_find(load_assets_dir + mc_character_directory, ".mimodel")) = 0 ||
				array_length_1d(file_find(load_assets_dir + mc_block_directory, ".json")) = 0 ||
				array_length_1d(file_find(load_assets_dir + mc_textures_directory + "blocks\\", ".png")) = 0)
				exists = false

			if (!exists)
			{
				debug_timer_start()
				if (unzip(load_assets_zip_file, load_assets_dir) = 0)
				{
					log("Could not unzip archive")
					access_error()
					return false
				}
				debug_timer_stop("Unzip archive")
			}
			else
				log("Archive already unzipped, re-using", load_assets_dir + mc_assets_directory)
			
			load_assets_stage = "textures"
			load_assets_progress = 0.3
			file_copy_temp = false
			break
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
	
			// Item textures
			var itemtextureslist = load_assets_map[?"item_textures"];
			if (is_undefined(itemtextureslist))
			{
				log("No item textures found")
				return false
			}
	
			ds_list_copy(item_texture_list, itemtextureslist)
	
			// Create sheets and texture depth
			with (mc_res)
			{
				res_load_pack_model_textures()
				res_load_pack_block_textures()
				res_load_pack_item_textures()
				res_load_pack_misc()
				res_update_colors(biome_list[|0])
			}
		
			load_assets_stage = "models"
			load_assets_progress = 0.4
			break
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
			load_assets_progress = 0.5
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
			
				// Save legacy ID in load_assets_map if available
				if (is_real(blockmap[?"legacy_id"]))
					block_legacy_id_map[?blockmap[?"legacy_id"]] = block
			
				ds_list_add(block_list, block)
				load_assets_block_index++
			}
			
			load_assets_progress = 0.5 + 0.5 * (load_assets_block_index / ds_list_size(blockslist))
	
			if (load_assets_stage = "done")
			{
				// Flowing Water/Lava
				block_name_map[?"flowing_water"] = block_name_map[?"water"]
				block_name_map[?"flowing_lava"] = block_name_map[?"lava"]
				block_legacy_id_map[?8] = block_legacy_id_map[?9]
				block_legacy_id_map[?10] = block_legacy_id_map[?11]
				block_liquid_slot_map[?"water"] = ds_list_find_index(block_texture_ani_list, "blocks/water_still")
				block_liquid_slot_map[?"lava"] = ds_list_find_index(block_texture_ani_list, "blocks/lava_still")
				block_liquid_slot_map[?"flowing_water"] = ds_list_find_index(block_texture_ani_list, "blocks/water_flow")
				block_liquid_slot_map[?"flowing_lava"] = ds_list_find_index(block_texture_ani_list, "blocks/lava_flow")
				
				debug_timer_stop("Load blocks")
	
				// Clear up loaded models
				key = ds_map_find_first(load_assets_model_file_map)
				while (!is_undefined(key))
				{
					with (load_assets_model_file_map[?key])
						instance_destroy()
					key = ds_map_find_next(load_assets_model_file_map, key)
				}
		
				file_copy_temp = true
				minecraft_assets_create_block_previews()
				
				ds_map_destroy(load_assets_model_file_map)
				ds_map_destroy(load_assets_map)
				ds_map_destroy(load_assets_type_map)
				buffer_delete(load_assets_block_preview_buffer)
				buffer_delete(load_assets_block_preview_ani_buffer)
				
				log("Loaded assets successfully")
			}
			
			break
		}
	}
		
	return true
}