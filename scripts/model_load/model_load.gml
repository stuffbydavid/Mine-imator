/// model_load(map, directory)
/// @arg map
/// @arg directory

function model_load(map, dir)
{
	with (new_obj(obj_model))
	{
		// Name
		if (is_string(map[?"name"]))
			name = map[?"name"]
		else
		{
			log("Could not find name for model")
			return null
		}
		
		if (dev_mode_debug_names && !text_exists("model" + name))
			log("model/" + name + dev_mode_name_translation_message)
		
		// File
		if (is_string(map[?"file"]))
			file = model_file_load(dir + map[?"file"])
		else
			file = null
		
		// Texture
		if (is_string(map[?"texture"]))
		{
			texture_name_map = ds_map_create()
			texture_name_map[?""] = map[?"texture"]
		}
		else if (ds_map_valid(map[?"texture"]))
		{
			texture_name_map = ds_map_create()
			ds_map_copy(texture_name_map, map[?"texture"])
		}
		else
			texture_name_map = null
		
		// Version
		version = value_get_real(map[?"version"], 0)
		
		// Pattern type
		pattern_type = value_get_string(map[?"pattern_type"], "")
		
		// Read states and their possible values
		states_map = null
		if (ds_map_valid(map[?"states"]))
		{
			states_map = ds_map_create()
			var curstate = ds_map_find_first(map[?"states"]);
			while (!is_undefined(curstate))
			{
				if (dev_mode_debug_names && !text_exists("modelstate" + curstate))
					log("model/state/" + curstate + dev_mode_name_translation_message)
				
				with (new_obj(obj_model_state))
				{
					name = curstate
					var valuelist = ds_map_find_value(map[?"states"], curstate);
					value_amount = ds_list_size(valuelist)
					
					for (var v = 0; v < value_amount; v++)
					{
						var curvalue = valuelist[|v];
						value_name[v] = curvalue[?"value"]
						value_file[v] = null
						value_texture_name_map[v] = null
						value_texture_material_name_map[v] = null
						value_tex_normal_name_map[v] = null
						value_shape_texture_name_map[v] = null
						value_shape_texture_material_name_map[v] = null
						value_shape_tex_normal_name_map[v] = null
						value_hide_list[v] = null
						value_shape_hide_list[v] = null
						value_color_name_map[v] = null
						value_pattern_type[v] = other.pattern_type
						
						if (dev_mode_debug_names && !text_exists("modelstatevalue" + value_name[v]))
							log("model/state/value/" + value_name[v] + dev_mode_name_translation_message)
						
						// File
						if (!is_undefined(curvalue[?"file"]))
							value_file[v] = model_file_load(dir + curvalue[?"file"])
						
						// Texture
						if (is_string(curvalue[?"texture"]))
						{
							var texnamemap = ds_map_create();
							texnamemap[?""] = curvalue[?"texture"]
							value_texture_name_map[v] = texnamemap
							
							// Material map
							texnamemap = ds_map_create()
							texnamemap[?""] = curvalue[?"texture"]
							value_texture_material_name_map[v] = texnamemap
							
							// Normal map
							texnamemap = ds_map_create()
							texnamemap[?""] = curvalue[?"texture"]
							value_tex_normal_name_map[v] = texnamemap
						}
						else if (ds_map_valid(curvalue[?"texture"]))
						{
							value_texture_name_map[v] = ds_map_create()
							ds_map_merge(value_texture_name_map[v], curvalue[?"texture"], true)
							
							// Material map
							value_texture_material_name_map[v] = ds_map_create()
							ds_map_merge(value_texture_material_name_map[v], curvalue[?"texture"], true)
							
							// Normal map
							value_tex_normal_name_map[v] = ds_map_create()
							ds_map_merge(value_tex_normal_name_map[v], curvalue[?"texture"], true)
						}
						
						// Shape texture
						if (is_string(curvalue[?"shape_texture"]))
						{
							var shapetexnamemap = ds_map_create();
							shapetexnamemap[?""] = curvalue[?"shape_texture"]
							value_shape_texture_name_map[v] = shapetexnamemap
							
							// Material map
							value_shape_texture_material_name_map = ds_map_create()
							shapetexnamemap[?""] = curvalue[?"shape_texture"]
							value_shape_texture_material_name_map[v] = shapetexnamemap
							
							// Normal map
							value_shape_tex_normal_name_map = ds_map_create()
							shapetexnamemap[?""] = curvalue[?"shape_texture"]
							value_shape_tex_normal_name_map[v] = shapetexnamemap
						}
						else if (ds_map_valid(curvalue[?"shape_texture"]))
						{
							value_shape_texture_name_map[v] = ds_map_create();
							ds_map_merge(value_shape_texture_name_map[v], curvalue[?"shape_texture"], true)
							
							// Material map
							value_shape_texture_material_name_map[v] = ds_map_create()
							ds_map_merge(value_shape_texture_material_name_map[v], curvalue[?"shape_texture"], true)
							
							// Normal map
							value_shape_tex_normal_name_map[v] = ds_map_create()
							ds_map_merge(value_shape_tex_normal_name_map[v], curvalue[?"shape_texture"], true)
						}
						
						// Hide parts
						if (ds_list_valid(curvalue[?"hide"]))
						{
							value_hide_list[v] = ds_list_create()
							ds_list_copy(value_hide_list[v], curvalue[?"hide"])
						}
						
						// Hide shapes
						if (ds_list_valid(curvalue[?"shape_hide"]))
						{
							value_shape_hide_list[v] = ds_list_create()
							ds_list_copy(value_shape_hide_list[v], curvalue[?"shape_hide"])
						}
						
						// Minecraft color palette(shapes)
						if (ds_map_valid(curvalue[?"shape_color"]))
						{
							value_color_name_map[v] = ds_map_create()
							ds_map_merge(value_color_name_map[v], curvalue[?"shape_color"], true)
						}
						
						// Pattern design
						if (!is_undefined(curvalue[?"pattern_type"]))
							value_pattern_type[v] = curvalue[?"pattern_type"]
					}
					
					other.states_map[?curstate] = id
					curstate = ds_map_find_next(map[?"states"], curstate)
				}
			}
		}
		
		// Default state
		if (is_string(map[?"default_state"]))
			default_state = string_get_state_vars(map[?"default_state"])
		else
			default_state = array()
		
		return id
	}
}
