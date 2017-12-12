/// project_load_timeline(map)
/// @arg map

var map = argument0;

if (!ds_map_valid(map))
	return 0

with (new(obj_timeline))
{
	loaded = true
	load_id = value_get_string(map[?"id"], save_id)
	save_id_map[?load_id] = load_id
	
	type = ds_list_find_index(tl_type_name_list, value_get_string(map[?"type"]))
	name = value_get_string(map[?"name"], name)
	
	temp = value_get_save_id(map[?"temp"], temp)
	color = value_get_color(map[?"color"], color)
	hide= value_get_real(map[?"hide"], hide)
	lock = value_get_real(map[?"lock"], lock)
	depth = value_get_real(map[?"depth"], depth)
	
	if (type = e_temp_type.BODYPART)
		model_part_name = value_get_string(map[?"model_part_name"], model_part_name)
		
	if (type = e_temp_type.TEXT)
		text = value_get_string(map[?"text"], text)
	
	part_of = value_get_save_id(map[?"part_of"], part_of)
	if (part_of != null)
	{
		if (type = e_temp_type.SPECIAL_BLOCK)
		{
			var modelmap = map[?"model"];
			if (ds_map_valid(modelmap))
			{
				model_name = value_get_string(modelmap[?"name"], "")
				model_state = value_get_state_vars(modelmap[?"state"])
			}
		}
		else if (type = e_temp_type.BLOCK)
		{
			var blockmap = map[?"block"];
			if (ds_map_valid(blockmap))
			{
				if (load_format < e_project.FORMAT_113)
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
					block_name = value_get_string(blockmap[?"name"], "")
					block_state = value_get_state_vars(blockmap[?"state"])
				}
			}
		}
	}
		
	var partslist = map[?"parts"];
	if (ds_list_valid(partslist))
	{
		part_list = ds_list_create()
		for (var p = 0; p < ds_list_size(partslist); p++)
			ds_list_add(part_list, partslist[|p])
	}
	
	// Default values
	project_load_values(map[?"default_values"], value_default)
	
	// Keyframes
	var kfmap = map[?"keyframes"];
	if (ds_map_valid(kfmap))
	{
		var key = ds_map_find_first(kfmap);
		keyframe_array = 0
		while (!is_undefined(key))
		{
			with (new(obj_keyframe))
			{
				position = string_get_real(key)
				loaded = true
				timeline = other.id
				selected = false
				sound_play_index = null
				
				for (var v = 0; v < e_value.amount; v++)
					value[v] = other.value_default[v]
					
				project_load_values(kfmap[?key], value)
				
				other.keyframe_array[position] = id
			}
			key = ds_map_find_next(kfmap, key)
		}
		
		// Create list (in the same order as position)
		for (var i = 0; i < array_length_1d(keyframe_array); i++)
			if (keyframe_array[i] > 0)
				ds_list_add(keyframe_list, keyframe_array[i])
	}
	
	parent = value_get_save_id(map[?"parent"], parent)
	parent_tree_index = value_get_real(map[?"parent_tree_index"], null)
	
	lock_bend = value_get_real(map[?"lock_bend"], lock_bend)
	tree_extend = value_get_real(map[?"tree_extend"], tree_extend)
	
	var inheritmap = map[?"inherit"];
	if (ds_map_valid(inheritmap))
	{
		inherit_position = value_get_real(inheritmap[?"position"], inherit_position)
		inherit_rotation = value_get_real(inheritmap[?"rotation"], inherit_rotation)
		inherit_rot_point = value_get_real(inheritmap[?"rot_point"], inherit_rot_point)
		inherit_scale = value_get_real(inheritmap[?"scale"], inherit_scale)
		inherit_alpha = value_get_real(inheritmap[?"alpha"], inherit_alpha)
		inherit_color = value_get_real(inheritmap[?"color"], inherit_color)
		inherit_visibility = value_get_real(inheritmap[?"visibility"], inherit_visibility)
		inherit_bend = value_get_real(inheritmap[?"bend"], inherit_bend)
		inherit_texture = value_get_real(inheritmap[?"texture"], inherit_texture)
	}
	
	scale_resize = value_get_real(map[?"scale_resize"], scale_resize)
	
	rot_point_custom = value_get_real(map[?"rot_point_custom"], rot_point_custom)
	rot_point = value_get_point3D(map[?"rot_point"], rot_point)
	
	backfaces = value_get_real(map[?"backfaces"], backfaces)
	texture_blur = value_get_real(map[?"texture_blur"], texture_blur)
	texture_filtering = value_get_real(map[?"texture_filtering"], texture_filtering)
	shadows = value_get_real(map[?"shadows"], shadows)
	ssao= value_get_real(map[?"ssao"], ssao)
	fog = value_get_real(map[?"fog"], fog)
	
	if (type = e_temp_type.SCENERY || type = e_temp_type.BLOCK || type = e_temp_type.PARTICLE_SPAWNER || type = e_temp_type.TEXT || type_is_shape(type))
	{
		wind = value_get_real(map[?"wind"], wind)
		wind_terrain = value_get_real(map[?"wind_terrain"], wind_terrain)
	}
}