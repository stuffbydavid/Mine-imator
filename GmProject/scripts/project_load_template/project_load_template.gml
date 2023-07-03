/// project_load_template(map)
/// @arg map

function project_load_template(map)
{
	if (!ds_map_valid(map))
		return 0
	
	with (new_obj(obj_template))
	{
		loaded = true
		
		load_id = value_get_string(map[?"id"], save_id)
		save_id_map[?load_id] = load_id
		
		type = ds_list_find_index(temp_type_name_list, value_get_string(map[?"type"]))
		name = value_get_string(map[?"name"], name)
		
		if (type = e_temp_type.CHARACTER || type = e_temp_type.SPECIAL_BLOCK || type = e_temp_type.BODYPART)
		{
			if (load_format = e_project.FORMAT_110_PRE_1)
				model_tex = value_get_save_id(map[?"skin"], model_tex)
			else
				model_tex = value_get_save_id(map[?"model_tex"], model_tex)
			
			if (load_format >= e_project.FORMAT_200_PRE_5)
			{
				model_tex_material = value_get_save_id(map[?"model_tex_material"], model_tex_material)
				model_tex_normal = value_get_save_id(map[?"model_tex_normal"], model_tex_normal)
			}
			else
			{
				model_tex_material = "default"
				model_tex_normal = "default"
			}
			
			model_use_blend_color = value_get_real(map[?"model_use_blend_color"], model_use_blend_color)
			model_blend_color = value_get_color(map[?"model_blend_color"], model_blend_color)
			
			var modelmap = map[?"model"];
			if (ds_map_valid(modelmap))
			{
				model_name = value_get_string(modelmap[?"name"], model_name)
				model_state = value_get_state_vars(modelmap[?"state"])
				
				// Update legacy model name 
				if (legacy_model_names_map[?model_name] != undefined)
					model_name = legacy_model_names_map[?model_name]
				
				// Update legacy model states
				if (legacy_model_states_map[?model_name] != undefined)
				{
					var legacymodelmap, statename;
					legacymodelmap = legacy_model_states_map[?model_name]
					
					for (var i = 0; i < array_length(model_state); i += 2)
					{
						statename = model_state[i]
					
						// Replace state name
						if (legacymodelmap[?statename] != undefined)
							model_state[i] = legacymodelmap[?statename]
					}
				}
				
				// Model version
				model_version = value_get_real(modelmap[?"model_version"], 0)
				if (!is_undefined(mc_assets.model_name_map[?model_name]) && mc_assets.model_name_map[?model_name].version > model_version)
				{
					load_update_tree = true
					
					// Add new states
					if (array_length(model_state) != array_length(mc_assets.model_name_map[?model_name].default_state))
					{
						var statesprev = array_copy_1d(model_state);
						model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
						state_vars_add(model_state, statesprev)
					}
					
					// Update legacy model state values
					if (legacy_model_state_values_map[?model_name] != undefined)
					{
						var legacymodelmap, statename;
						legacymodelmap = legacy_model_state_values_map[?model_name]
						
						for (var i = 0; i < array_length(model_state); i += 2)
						{
							statename = model_state[i]
							
							if (legacymodelmap[?statename] != undefined)
							{
								var statemap, statevalue;
								statemap = legacymodelmap[?statename]
								statevalue = model_state[i + 1]
								
								if (ds_map_valid(statemap[?statevalue])) // Replace multiple/different values
								{
									var valmap = statemap[?statevalue];
									
									// Look for values and update
									for (var j = 0; j < array_length(model_state); j += 2)
									{
										var state = model_state[j];
										
										if (valmap[?state] != undefined)
											model_state[j + 1] = valmap[?state]
									}
								}
								else // Replace single value
								{
									if (statemap[?statevalue] != undefined)
										model_state[i + 1] = statemap[?statevalue]
								}
							}
						}
					}
				}
				
				if (type = e_temp_type.BODYPART)
					model_part_name = value_get_string(modelmap[?"part_name"], model_part_name)
				
				// Pattern values
				var valname = (load_format < e_project.FORMAT_200_PRE_5 ? "banner_base_color" : "pattern_base_color");
				if (!is_undefined(map[?valname]))
				{
					var base_color, pattern_list, color_list;
					
					if (load_format < e_project.FORMAT_200_PRE_5)
					{
						base_color = value_get_string(map[?"banner_base_color"], "white")
						pattern_list = map[?"banner_pattern_list"]
						color_list = map[?"banner_color_list"]
					}
					else
					{
						base_color = value_get_string(map[?"pattern_base_color"], "white")
						pattern_list = map[?"pattern_pattern_list"]
						color_list = map[?"pattern_color_list"]
					}
					
					pattern_base_color = minecraft_swatch_dyes.map[?base_color]
					
					if (ds_list_valid(pattern_list))
					{
						for (var p = 0; p < ds_list_size(pattern_list); p++)
							array_add(pattern_pattern_list, pattern_list[|p])
					}
					
					if (ds_list_valid(color_list))
					{
						for (var c = 0; c < ds_list_size(color_list); c++)
							array_add(pattern_color_list, minecraft_swatch_dyes.map[? color_list[|c]])
					}
				}
				
				if (model_name = "armor")
				{
					if (map[?"armor"] != undefined)
					{
						var armor = map[?"armor"];
						armor_array[1] = value_get_color(armor[?"helmet_dye"], armor_array[1])
						armor_array[2] = value_get_string(armor[?"helmet_trim_pattern"], armor_array[2])
						armor_array[3] = value_get_string(armor[?"helmet_trim_material"], armor_array[3])

						armor_array[5] = value_get_color(armor[?"chestplate_dye"], armor_array[5])
						armor_array[6] = value_get_string(armor[?"chestplate_trim_pattern"], armor_array[6])
						armor_array[7] = value_get_string(armor[?"chestplate_trim_material"], armor_array[7])

						armor_array[9] = value_get_color(armor[?"leggings_dye"], armor_array[9])
						armor_array[10] = value_get_string(armor[?"leggings_trim_pattern"], armor_array[10])
						armor_array[11] = value_get_string(armor[?"leggings_trim_material"], armor_array[11])

						armor_array[13] = value_get_color(armor[?"boots_dye"], armor_array[13])
						armor_array[14] = value_get_string(armor[?"boots_trim_pattern"], armor_array[14])
						armor_array[15] = value_get_string(armor[?"boots_trim_material"], armor_array[15])
					}
				}
			}
		}
		else if (type = e_temp_type.ITEM)
		{
			var itemmap = map[?"item"];
			if (ds_map_valid(itemmap))
			{
				item_tex = value_get_save_id(itemmap[?"tex"], item_tex)
				item_tex_material = value_get_save_id(itemmap[?"tex_material"], item_tex_material)
				item_tex_normal = value_get_save_id(itemmap[?"tex_normal"], item_tex_normal)
				
				var itemname = itemmap[?"name"];
				if (is_string(itemname))
				{
					if (load_format < e_project.FORMAT_120_PRE_1)
					{
						itemname = string_replace(itemname, "items/", "item/")
						var newname = ds_map_find_key(legacy_item_texture_name_map, itemname);
						if (!is_undefined(newname))
							itemname = newname
					}
					item_slot = ds_list_find_index(mc_assets.item_texture_list, itemname)
					if (item_slot < 0)
						item_slot = ds_list_find_index(mc_assets.item_texture_list, default_item)
				}
				else
					item_slot = value_get_real(itemmap[?"slot"], item_slot)
				item_3d = value_get_real(itemmap[?"3d"], item_3d)
				item_face_camera = value_get_real(itemmap[?"face_camera"], item_face_camera)
				item_bounce = value_get_real(itemmap[?"bounce"], item_bounce)
				item_spin = value_get_real(itemmap[?"spin"], item_spin)
			}
		}
		else if (type = e_temp_type.BLOCK)
		{
			var blockmap = map[?"block"];
			if (ds_map_valid(blockmap))
			{
				if (load_format < e_project.FORMAT_120_PRE_1)
				{
					// Read legacy block
					var bid = value_get_real(blockmap[?"legacy_id"], 2);
					var bdata = value_get_real(blockmap[?"legacy_data"], 0);
					if (legacy_block_set[bid])
					{
						var block = legacy_block_obj[bid, bdata];
						if (block != null)
						{
							block_name = block.name
							block_state = block_get_state_id_state_vars(block, legacy_block_state_id[bid, bdata])
						}
					}
				}
				else
				{
					block_name = value_get_string(blockmap[?"name"], block_name)
					
					// Update legacy block name
					if (legacy_block_names_map[?block_name] != undefined)
						block_name = legacy_block_names_map[?block_name]
					
					block_state = value_get_state_vars(blockmap[?"state"])
				}
				
				block_tex = value_get_save_id(blockmap[?"tex"], block_tex)
				
				if (load_format >= e_project.FORMAT_200_PRE_5)
				{
					block_tex_material = value_get_save_id(blockmap[?"tex_material"], block_tex_material)
					block_tex_normal = value_get_save_id(blockmap[?"tex_normal"], block_tex_normal)
				}
				else
				{
					block_tex_material = "default"
					block_tex_normal = "default"
				}
				
				block_randomize = value_get_real(blockmap[?"randomize"], block_randomize)
				block_repeat_enable = value_get_real(blockmap[?"repeat_enable"], block_repeat_enable)
				block_repeat = value_get_point3D(blockmap[?"repeat"], block_repeat)
			}
		}
		else if (type = e_temp_type.SCENERY)
		{
			scenery = value_get_save_id(map[?"scenery"], scenery)
			var blockmap = map[?"block"];
			if (ds_map_valid(blockmap))
			{
				block_tex = value_get_save_id(blockmap[?"tex"], block_tex)
				
				if (load_format >= e_project.FORMAT_200_PRE_5)
				{
					block_tex_material = value_get_save_id(blockmap[?"tex_material"], block_tex_material)
					block_tex_normal = value_get_save_id(blockmap[?"tex_normal"], block_tex_normal)
					
					// Bugfix for scenery imported in Pre-release 5
					if (block_tex_material = null)
						block_tex_material = "default"
					
					if (block_tex_normal = null)
						block_tex_normal = "default"
				}
				else
				{
					block_tex_material = "default"
					block_tex_normal = "default"
				}
				
				block_repeat_enable = value_get_real(blockmap[?"repeat_enable"], block_repeat_enable)
				block_repeat = value_get_point3D(blockmap[?"repeat"], block_repeat)
			}
		}
		else if (type = e_temp_type.MODEL)
		{
			model = value_get_save_id(map[?"model"], model)
			model_tex = value_get_save_id(map[?"model_tex"], model_tex)	
			
			if (load_format >= e_project.FORMAT_200_PRE_5)
			{
				model_tex_material = value_get_save_id(map[?"model_tex_material"], model_tex_material)
				model_tex_normal = value_get_save_id(map[?"model_tex_normal"], model_tex_normal)
			}
			else
			{
				model_tex_material = "default"
				model_tex_normal = "default"
			}
		}
		
		if (type_is_shape(type))
		{
			var shapemap = map[?"shape"];
			if (ds_map_valid(shapemap))
			{
				shape_tex = value_get_save_id(shapemap[?"tex"], shape_tex)
				shape_tex_material = value_get_save_id(shapemap[?"tex_material"], shape_tex_material)
				shape_tex_normal = value_get_save_id(shapemap[?"tex_normal"], shape_tex_normal)
				shape_tex_mapped = value_get_real(shapemap[?"tex_mapped"], shape_tex_mapped)
				shape_tex_hoffset = value_get_real(shapemap[?"tex_hoffset"], shape_tex_hoffset)
				shape_tex_voffset = value_get_real(shapemap[?"tex_voffset"], shape_tex_voffset)
				shape_tex_hrepeat = value_get_real(shapemap[?"tex_hrepeat"], shape_tex_hrepeat)
				shape_tex_vrepeat = value_get_real(shapemap[?"tex_vrepeat"], shape_tex_vrepeat)
				shape_tex_hmirror = value_get_real(shapemap[?"tex_hmirror"], shape_tex_hmirror)
				shape_tex_vmirror = value_get_real(shapemap[?"tex_vmirror"], shape_tex_vmirror)
				shape_closed = value_get_real(shapemap[?"closed"], shape_closed)
				shape_invert = value_get_real(shapemap[?"invert"], shape_invert)
				shape_detail = value_get_real(shapemap[?"detail"], shape_detail)
				shape_face_camera = value_get_real(shapemap[?"face_camera"], shape_face_camera)
				
				// Bugfix for types that don't support tex mapping
				if (type != e_temp_type.CUBE && type != e_temp_type.CYLINDER && type != e_temp_type.CONE)
					shape_tex_mapped = false
			}
		}
		else if (type = e_temp_type.TEXT)
		{
			var textmap = map[?"text"];
			if (ds_map_valid(textmap))
			{
				text_font = value_get_save_id(textmap[?"font"], text_font)
				text_3d = value_get_real(textmap[?"3d"], text_3d)
				text_face_camera = value_get_real(textmap[?"face_camera"], text_face_camera)
			}
		}
		else if (type = e_temp_type.PARTICLE_SPAWNER)
			project_load_particles(map[?"particles"])
		
		if (temp_creator = app)
			sortlist_add(app.lib_list, id)
	}
}
