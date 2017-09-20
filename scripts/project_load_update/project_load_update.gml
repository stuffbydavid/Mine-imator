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

// Update schematic parts
with (obj_timeline)
{
	if (part_of != null)
	{
		if (type = "spblock")
		{
			skin = res_def
			model_state_map = null
			model_file = null
			model_texture_name_map = null
			temp_update_model_state_map()
			temp_update_model()
			temp_update_model_timeline_parts()
		}
		else if (type = "block")
		{
			block_tex = res_def
			block_state_map = null
			block_repeat_enable = false
			block_repeat = vec3(1)
			block_vbuffer_reset()
			temp_update_block_state_map()
			temp_update_block()
		}
		else if (type = "text")
		{
			text_font = res_def
			text_3d = false
			text_face_camera = false
		}
	}
}

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