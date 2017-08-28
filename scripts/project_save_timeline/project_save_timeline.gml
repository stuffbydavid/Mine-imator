/// project_save_timeline()

json_export_object_start()

	json_export_var("id", save_id)
	json_export_var("type", type)
	json_export_var("name", json_string_escape(name))
	
	json_export_var_save_id("temp", temp)
	json_export_var("text", json_string_escape(text))
	json_export_var_color("color", color)
	json_export_var_bool("hide", hide)
	json_export_var_bool("lock", lock)
	json_export_var("depth", depth)
	
	if (type = "bodypart")
		json_export_var("model_part_name", model_part_name)
	
	if (part_list != null)
	{
		json_export_array_start("parts")
		
		for (var p = 0; p < ds_list_size(part_list); p++)
			json_export_array_value(save_id_get(part_list[|p]))
		
		json_export_array_done()
	}
	
	project_save_values("default_values", value_default, app.value_default)
	
	json_export_object_start("keyframes")
	
		for (var k = 0; k < ds_list_size(keyframe_list); k++)
			with (keyframe_list[|k])
				project_save_values(string(position), value, other.value_default)

	json_export_object_done()
	
	json_export_var_save_id("parent", parent)
	json_export_var("parent_tree_index", ds_list_find_index(parent.tree_list, id))
	
	json_export_var_bool("lock_bend", lock_bend)
	json_export_var_bool("tree_extend", tree_extend)
	
	json_export_object_start("inherit")
		json_export_var_bool("position", inherit_position)
		json_export_var_bool("rotation", inherit_rotation)
		json_export_var_bool("scale", inherit_scale)
		json_export_var_bool("alpha", inherit_alpha)
		json_export_var_bool("color", inherit_color)
		json_export_var_bool("texture", inherit_texture)
		json_export_var_bool("visibility", inherit_visibility)
	json_export_object_done()
	
	json_export_var_bool("scale_resize", scale_resize)
	
	json_export_var_bool("rot_point_custom", rot_point_custom)
	json_export_var("rot_point", rot_point)
	
	json_export_var_bool("backfaces", backfaces)
	json_export_var_bool("texture_blur", texture_blur)
	json_export_var_bool("texture_filtering", texture_filtering)
	json_export_var_bool("round_bending", round_bending)
	json_export_var_bool("shadows", shadows)
	json_export_var_bool("ssao", ssao)
	json_export_var_bool("fog", fog)
	json_export_var_bool("wind", wind)
	json_export_var_bool("wind_terrain", wind_terrain)

json_export_object_done()