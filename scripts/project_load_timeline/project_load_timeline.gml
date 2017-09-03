/// project_load_timeline(map)
/// @arg map

var map = argument0;

if (!ds_exists(map, ds_type_map))
	return 0

with (new(obj_timeline))
{
	loaded = true
	
	save_id = json_read_string(map[?"id"], save_id)
	save_id_map[?save_id] = save_id
	
	type = json_read_string(map[?"type"], type)
	name = json_read_string(map[?"name"], name)
	
	temp = json_read_save_id(map[?"temp"], temp)
	text = json_read_string(map[?"text"], text)
	color = json_read_color(map[?"color"], color)
	hide= json_read_real(map[?"hide"], hide)
	lock = json_read_real(map[?"lock"], lock)
	depth = json_read_real(map[?"depth"], depth)
	
	if (type = "bodypart")
		model_part_name = json_read_string(map[?"model_part_name"], model_part_name)
		
	if (type = "char" || type = "spblock")
	{
		part_list = ds_list_create()
		var partslist = map[?"parts"];
		for (var p = 0; p < ds_list_size(partslist); p++)
			ds_list_add(part_list, partslist[|p])
	}
	
	// Default values
	project_load_values(map[?"default_values"], value_default)
	
	// Keyframes
	var kfmap = map[?"keyframes"];
	if (ds_exists(kfmap, ds_type_map))
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
	
	parent = json_read_save_id(map[?"parent"], parent)
	parent_tree_index = json_read_real(map[?"parent_tree_index"], null)
	
	lock_bend = json_read_real(map[?"lock_bend"], lock_bend)
	tree_extend = json_read_real(map[?"tree_extend"], tree_extend)
	
	var inheritmap = map[?"inherit"];
	if (ds_exists(inheritmap, ds_type_map))
	{
		inherit_position = json_read_real(inheritmap[?"position"], inherit_position)
		inherit_rotation = json_read_real(inheritmap[?"rotation"], inherit_rotation)
		inherit_scale = json_read_real(inheritmap[?"scale"], inherit_scale)
		inherit_alpha = json_read_real(inheritmap[?"alpha"], inherit_alpha)
		inherit_color = json_read_real(inheritmap[?"color"], inherit_color)
		inherit_texture = json_read_real(inheritmap[?"texture"], inherit_texture)
		inherit_visibility = json_read_real(inheritmap[?"visibility"], inherit_visibility)
	}
	
	scale_resize = json_read_real(map[?"scale_resize"], scale_resize)
	
	rot_point_custom = json_read_real(map[?"rot_point_custom"], rot_point_custom)
	rot_point = json_read_array(map[?"rot_point"], rot_point)
	
	backfaces = json_read_real(map[?"backfaces"], backfaces)
	texture_blur = json_read_real(map[?"texture_blur"], texture_blur)
	texture_filtering = json_read_real(map[?"texture_filtering"], texture_filtering)
	if (type = "bodypart")
		round_bending = json_read_real(map[?"round_bending"], round_bending)
	shadows = json_read_real(map[?"shadows"], shadows)
	ssao= json_read_real(map[?"ssao"], ssao)
	fog = json_read_real(map[?"fog"], fog)
	
	if (type = "scenery" || type = "block" || type = "particles" || type = "text" || type_is_shape(type))
	{
		wind = json_read_real(map[?"wind"], wind)
		wind_terrain = json_read_real(map[?"wind_terrain"], wind_terrain)
	}
}