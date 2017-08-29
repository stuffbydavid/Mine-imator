/// project_load_update()
/// @desc Update program after reading a file.

background_sky_update_clouds()
background_ground_update_texture()

with (obj_template)
{
    temp_update()
	if (type = "char" || type = "spblock" || type = "bodypart")
	{
		if (load_format >= e_project.FORMAT_110)
			temp_update_model_timeline_parts()
		else
			temp_update_model_timeline_tree()
	}
}

with (obj_timeline)
{
	tl_update()
    tl_update_values()
}

with (obj_resource)
    res_update_colors()

project_reset_loaded()
tl_update_length()
tl_update_list()
tl_update_matrix()
