/// project_read_update()
/// @desc Update program after reading a file.

log("Update program")
background_sky_update_clouds()
background_ground_update_texture()

with (obj_resource)
	res_update_colors()

with (obj_template)
{
	temp_update_display_name()
	temp_update_rot_point()
	if (type = "item")
		temp_update_item()
	if (type = "block")
		temp_update_block()
	if (type_is_shape(type))
		temp_update_shape()
}

with (obj_timeline)
{
	tl_update_type_name()
	tl_update_display_name()
	tl_update_rot_point()
	if (type = "particles")
		particle_spawner_init()
	tl_update_values()
	tl_update_depth()
}

project_reset_loaded()
tl_update_length()
tl_update_list()
tl_update_matrix()
