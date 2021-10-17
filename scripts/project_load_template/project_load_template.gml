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
			
			if (load_format < e_project.FORMAT_200_AL17)
			{
				model_tex_material = "default"
				model_tex_normal = "default"
			}
			else
			{
				model_tex_material = value_get_save_id(map[?"model_tex_material"], model_tex_material)
				model_tex_normal = value_get_save_id(map[?"model_tex_normal"], model_tex_normal)
			}
			
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
					var modelmap, statename;
					modelmap = legacy_model_states_map[?model_name]
					
					for (var i = 0; i < array_length(model_state); i += 2)
					{
						statename = model_state[i]
					
						// Replace state name
						if (modelmap[?statename] != undefined)
							model_state[i] = modelmap[?statename]
					}
				}
				
				// Model version
				if (type = e_temp_type.CHARACTER || type = e_temp_type.SPECIAL_BLOCK)
				{
					model_version = value_get_real(modelmap[?"model_version"], 0)
					if (mc_assets.model_name_map[?model_name].version > model_version)
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
							var modelmap, statename;
							modelmap = legacy_model_state_values_map[?model_name]
							
							for (var i = 0; i < array_length(model_state); i += 2)
							{
								statename = model_state[i]
								
								if (modelmap[?statename] != undefined)
								{
									var statemap, statevalue;
									statemap = modelmap[?statename]
									statevalue = model_state[i + 1]
									
									// Replace model state value with value from map
									if (statemap[?statevalue] != undefined)
										model_state[i + 1] = statemap[?statevalue]
								}
							}
						}
					}
				}
				
				if (type = e_temp_type.BODYPART)
					model_part_name = value_get_string(modelmap[?"part_name"], model_part_name)
				
				// Banner values
				if (model_name = "banner")
				{
					var base_color, pattern_list, color_list; 
					base_color = value_get_string(map[?"banner_base_color"], "white")
					pattern_list = map[?"banner_pattern_list"]
					color_list = map[?"banner_color_list"]
					
					banner_base_color = minecraft_color_list[|ds_list_find_index(minecraft_color_name_list, base_color)]
					
					if (ds_list_valid(pattern_list))
					{
						for (var p = 0; p < ds_list_size(pattern_list); p++)
							array_add(banner_pattern_list, pattern_list[|p])
					}
					
					if (ds_list_valid(color_list))
					{
						for (var c = 0; c < ds_list_size(color_list); c++)
							array_add(banner_color_list, minecraft_color_list[|ds_list_find_index(minecraft_color_name_list, color_list[|c])])
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
				
				if (load_format >= e_project.FORMAT_200_AL17)
				{
					block_tex_material = value_get_save_id(blockmap[?"tex_material"], block_tex_material)
					block_tex_normal = value_get_save_id(blockmap[?"tex_normal"], block_tex_normal)
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
		else if (type = e_temp_type.SCENERY)
		{
			scenery = value_get_save_id(map[?"scenery"], scenery)
			var blockmap = map[?"block"];
			if (ds_map_valid(blockmap))
			{
				block_tex = value_get_save_id(blockmap[?"tex"], block_tex)
				
				if (load_format >= e_project.FORMAT_200_AL17)
				{
					block_tex_material = value_get_save_id(blockmap[?"tex_material"], block_tex_material)
					block_tex_normal = value_get_save_id(blockmap[?"tex_normal"], block_tex_normal)
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
			
			if (load_format < e_project.FORMAT_200_AL17)
			{
				model_tex_material = "default"
				model_tex_normal = "default"
			}
			else
			{
				model_tex_material = value_get_save_id(map[?"model_tex_material"], model_tex_material)
				model_tex_normal = value_get_save_id(map[?"model_tex_normal"], model_tex_normal)
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
