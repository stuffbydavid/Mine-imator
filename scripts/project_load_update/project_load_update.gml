/// project_load_update()
/// @desc Update program after reading a file.

// Load resources
with (obj_resource)
	if (loaded)
		res_load()
		
if (ds_priority_size(load_queue) > 0)
	load_start(ds_priority_find_max(load_queue), res_load_start)
else
	popup_close()
	
// Update sky
background_sky_update_clouds()
background_ground_update_texture()

// Update templates and timelines
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

with (obj_particle_type)
	ptype_update_sprite_vbuffers()
	
tl_update_length()
tl_update_list()
tl_update_matrix()