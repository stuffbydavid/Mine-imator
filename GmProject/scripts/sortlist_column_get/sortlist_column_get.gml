/// @desc Returns the string to display at a column for the value.
/// @arg sortlist
/// @arg value
/// @arg column

function sortlist_column_get(slist, value, col)
{
	switch (slist.column_name[col])
	{
		case "build_name":
		{
			if (value[0])
				return minecraft_asset_get_name("model", value[1])
			
			return minecraft_asset_get_name("block", value[1])
		}
		
		case "lib_name":
		{
			if (debug_saveid)
				return string_remove_newline(value.display_name) + " [" + string(value.save_id) + "]"
			
			return string_remove_newline(value.display_name)
		}
		
		case "lib_type":
			return text_get("type/" + temp_type_name_list[|value.type])
		
		case "lib_instances":
			return value.count = -1 ? "-" : value.count
		
		case "char_name":
		case "special_block_name":
		case "model_part_model_name":
		{
			if (is_undefined(mc_assets.model_name_map[?value]))
				return 0
			
			return minecraft_asset_get_name("model", mc_assets.model_name_map[?value].name)
		}
		
		case "block_name":
		{
			if (is_undefined(mc_assets.block_name_map[?value]))
				return 0
			
			return minecraft_asset_get_name("block", mc_assets.block_name_map[?value].name)
		}
		
		case "block_filter":
			return minecraft_asset_get_name("block", mc_assets.block_list[|value].name)
		
		case "scenery_name":
		case "schematic_name":
		{
			if (!is_string(value))
				return value.display_name

			var fn = filename_new_ext(filename_name(value), "");
			return text_exists("bench/schematic/" + fn) ? text_get("bench/schematic/" + fn) : fn
		}
		
		case "shape_name":
			return text_get("type/" + tl_type_name_list[|e_tl_type.CUBE + value])
		
		case "camera_effect_name":
			return text_get("frame_editor/camera_effect/" + camera_effect_name_list[|value])
		
		case "particle_editor_type_name":
		{
			if (debug_saveid)
				return string_remove_newline(value.name) + " [" + string(value.save_id) + "]"
			
			return string_remove_newline(value.name)
		}
		
		case "particle_editor_type_kind":
		{
			if (value.temp = particle_sheet)
				return text_get("particle_editor/type/sprite_sheet")
			else if (value.temp = particle_template)
				return text_get("particle_editor/type/template")
			else
				return string_remove_newline(value.temp.display_name)
		}
		
		case "particle_editor_type_rate":
			return string(floor(value.spawn_rate * 100)) + "%"
		
		case "project_name":
		case "res_name":
		{
			if (debug_saveid)
				return string_remove_newline(value.display_name) + " [" + string(value.save_id) + "]"
			
			return string_remove_newline(value.display_name)
		}
		
		case "project_type":
		{
			if (value.object_index = obj_resource)
				return text_get("type/" + res_type_name_list[|value.type])
			
			return text_get("type/" + temp_type_name_list[|value.type])
		}
		
		case "resfilename":
			return string_remove_newline(value.filename)
		
		case "res_type":
			return text_get("type/" + res_type_name_list[|value.type])
		
		case "project_count":
		case "res_count":
			return value.count = -1 ? "-" : value.count
		
		case "particle_preset_name":
		{
			if (!is_string(value))
				return string_remove_newline(value.display_name)

			var fn = filename_new_ext(filename_name(value), "");
			return text_exists("bench/particles/" + fn) ? text_get("bench/particles/" + fn) : fn
		}
	}
}
