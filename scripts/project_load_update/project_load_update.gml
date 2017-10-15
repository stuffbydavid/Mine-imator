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
if (background_loaded)
{
	background_sky_update_clouds()
	background_ground_update_texture()
}

// Update scenery parts
with (obj_timeline)
	if (loaded && part_of != null)
		tl_update_scenery_part()

// Update templates and timelines
with (obj_template)
{
	if (!loaded)
		continue
	
	temp_update()
	
	if (type = e_temp_type.CHARACTER || type = e_temp_type.SPECIAL_BLOCK || type = e_temp_type.BODYPART)
	{
		if (load_format >= e_project.FORMAT_110_PRE_1)
			temp_update_model_timeline_parts()
		else
			temp_update_model_timeline_tree()
	}
		
}

with (obj_timeline)
{
	if (!loaded)
		continue
		
	tl_update()
	tl_update_values()
	
	// Animate scenery
	if (type = e_tl_type.SCENERY && temp.scenery != null && load_format < e_project.FORMAT_110_PRE_1)
	{
		if (temp.scenery.ready)
			tl_animate_scenery()
		else
			scenery_animate = true
	}
}

with (obj_particle_type)
	if (loaded)
		ptype_update_sprite_vbuffers()
	
tl_update_length()
tl_update_list()
tl_update_matrix()