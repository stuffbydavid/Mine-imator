/// project_load_legacy_timeline()

with (new(obj_timeline))
{
	loaded = true
	load_id = buffer_read_int()
	save_id_map[?load_id] = load_id
	
	var typename = buffer_read_string_int();
	type = ds_list_find_index(tl_type_name_list, typename)
	
	name = buffer_read_string_int()
	temp = project_load_legacy_save_id()
	text = buffer_read_string_int()
	color = buffer_read_int()
	if (load_format < e_project.FORMAT_100_DEBUG) // Color too bright
		color = make_color_hsv(color_get_hue(color), 255, 128)

	lock = buffer_read_byte()
	if (load_format < e_project.FORMAT_100_DEBUG)
		lock = !lock
	if (load_format >= e_project.FORMAT_100_DEBUG)
		depth = buffer_read_int()

	legacy_bodypart_id = buffer_read_short()
	if (type = e_temp_type.BODYPART)
	{
		// Find part model
		var findtemp;
		with (obj_template)
		{
			if (loaded && load_id = other.temp)
			{
				temp_update_model()
				findtemp = id
				break
			}
		}
		
		// Find name from ID
		var modelpartlist = legacy_model_part_map[?findtemp.model_name];
		if (!is_undefined(modelpartlist) && legacy_bodypart_id < ds_list_size(modelpartlist))
		{
			model_part_name = modelpartlist[|legacy_bodypart_id]
		
			// Find part model by looking through model file for the name
			if (findtemp.model_file != null)
			{
				var filepartlist = findtemp.model_file.file_part_list;
				for (var i = 0; i < ds_list_size(filepartlist); i++)
				{
					var part = filepartlist[|i];
					if (part.name = model_part_name)
					{
						model_part = part
						break
					}
				}
			}
		}
		else
			log("Could not find model part for", findtemp.model_name, findtemp.legacy_model_name, legacy_bodypart_id)
	}
	
	part_of = project_load_legacy_save_id()
	
	if (type = e_temp_type.CHARACTER || type = e_temp_type.SPECIAL_BLOCK)
		part_list = ds_list_create()
		
	part_amount = buffer_read_short()
	for (var p = 0; p < part_amount; p++)
		ds_list_add(part_list, project_load_legacy_save_id())

	hide = buffer_read_byte()
	
	if (load_format >= e_project.FORMAT_100_DEMO_3)
		project_load_legacy_value_types()
	else
		tl_update_value_types()

	if (load_format >= e_project.FORMAT_100_DEMO_4)
		project_load_legacy_values(id)

	keyframe_amount = buffer_read_int()
	if (keyframe_amount = 0)
		for (var v = 0; v < e_value.amount; v++)
			value_default[v] = value[v]

	for (var k = 0; k < keyframe_amount; k++)
	{
		with (new(obj_keyframe))
		{
			loaded = true
			position = buffer_read_int()
			timeline = other.id
			selected = false
			sound_play_index = null
			
			for (var v = 0; v < e_value.amount; v++)
				value[v] = other.value[v]
			project_load_legacy_values(other.id)
			
			ds_list_add(other.keyframe_list, id)
		}
	}
	
	parent = project_load_legacy_save_id()
	if (load_format >= e_project.FORMAT_100_DEBUG)
		parent_tree_index = buffer_read_int()
	else
		parent_tree_index = null

	lock_bend = buffer_read_byte()

	if (load_format < e_project.FORMAT_100_DEBUG)
		repeat (buffer_read_int())
			buffer_read_int()

	tree_extend = buffer_read_byte()
	inherit_position = buffer_read_byte()
	inherit_rotation = buffer_read_byte()
	inherit_scale = buffer_read_byte()
	inherit_alpha = buffer_read_byte()
	inherit_color = buffer_read_byte()
	inherit_texture = buffer_read_byte()
	inherit_visibility = buffer_read_byte()
	inherit_rot_point = (type = e_tl_type.BODYPART)
	scale_resize = buffer_read_byte()
	rot_point_custom = buffer_read_byte()

	rot_point[X] = buffer_read_double()
	rot_point[Y] = buffer_read_double()
	rot_point[Z] = buffer_read_double()
	if (rot_point_custom && load_format < e_project.FORMAT_100_DEBUG && type_is_shape(type))
	{
		rot_point[X] -= 8
		rot_point[Y] -= 8
		if (type != e_temp_type.SURFACE)
			rot_point[Z] -= 8
	}
	
	if (part_of != null)
		rot_point = point3D(0, 0, 0)
	
	backfaces = buffer_read_byte()
	texture_blur = buffer_read_byte()
	if (load_format >= e_project.FORMAT_100_DEBUG)
		texture_filtering = buffer_read_byte()
	else
		texture_filtering = (type = e_temp_type.SCENERY || type=e_temp_type.BLOCK)
	round_bending = buffer_read_byte()
	shadows = buffer_read_byte()
	if (load_format >= e_project.FORMAT_100_DEBUG)
	{
		ssao = buffer_read_byte()
		if (load_format >= e_project.FORMAT_105_2)
			fog = buffer_read_byte()
		wind = buffer_read_byte()
		wind_amount = buffer_read_double()
	}
	wind_terrain = buffer_read_byte()

	if (load_format >= e_project.FORMAT_CB_100) 
	{
		inherit_bend = buffer_read_byte()
		
		// Reset bend to 0
		if (inherit_bend)
		{
			value[e_value.BEND_ANGLE] = 0
			for (var i = 0; i < ds_list_size(keyframe_list); i++)
				with (keyframe_list[|i])
					value[e_value.BEND_ANGLE]= 0
		}
		
		/*hide_quality_high = */buffer_read_byte()
		/*hide_quality_low = */buffer_read_byte()
		/*biome = */buffer_read_byte()
	}
}
