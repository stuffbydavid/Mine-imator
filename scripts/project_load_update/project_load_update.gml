/// project_load_update()
/// @desc Update program after reading a file.

background_sky_update_clouds()
background_ground_update_texture()

with (obj_template)
{
    temp_update()
	temp_update_model_timeline_parts()
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
