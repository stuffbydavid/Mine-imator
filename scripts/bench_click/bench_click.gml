/// bench_click(type)
/// @arg type

with (bench_settings)
{
	type = argument0

	// Switch to character
	if (type = e_tl_type.CHARACTER)
	{
		if (ds_list_find_index(char_list.list, model_name) < 0)
		{
			model_name = default_model
			model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
		}
		model_tex = mc_res
		temp_update_model()
		temp_update_model_shape()
	}
	
	// Switch to special block
	if (type = e_tl_type.SPECIAL_BLOCK)
	{
		if (ds_list_find_index(special_block_list.list, model_name) < 0)
		{
			model_name = default_special_block
			model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
		}
		model_tex = mc_res
		temp_update_model()
		temp_update_model_shape()
	}
	
	// Switch to bodypart
	if (type = e_tl_type.BODYPART)
	{
		model_tex = mc_res
		temp_update_model()
		temp_update_model_part()
		temp_update_model_shape()
	}
	
	// Switch to block
	if (type = e_tl_type.BLOCK)
		temp_update_block()
		
	// Switch to item
	if (type = e_tl_type.ITEM)
		render_generate_item()
	
	// Switch to shape
	if (type = e_tl_type.SHAPE)
		temp_update_shape()
		
	// Switch to model
	if (type = e_tl_type.MODEL)
	{
		model_tex = null
		temp_update_model()
		temp_update_model_shape()
		
		// Modelbench popup
		if (show_modelbench_popup)
			with (app)
				if (!popup_modelbench.hidden && !popup_modelbench.not_now)
					popup_show(popup_modelbench)
	}
}

// Switch to particles
if (bench_settings.type = e_tl_type.PARTICLE_SPAWNER)
	bench_update_particles_list()

with (bench_settings.preview)
{
	particle_spawner_clear()
	preview_reset_view()
	update = true
}

bench_clear()