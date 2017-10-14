/// bench_click(type)
/// @arg type

with (bench_settings)
{
	type = argument0

	// Switch to character
	if (type = e_temp_type.CHARACTER && ds_list_find_index(char_list.list, model_name) < 0)
	{
		model_name = "human"
		model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
		temp_update_model()
	}
	
	// Switch to special block
	if (type = e_temp_type.SPECIAL_BLOCK && ds_list_find_index(special_block_list.list, model_name) < 0)
	{
		model_name = "chest"
		model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
		temp_update_model()
	}
	
	// Switch to bodypart
	if (type = e_temp_type.BODYPART)
		temp_update_model_part()
	
	// Switch to block
	if (type = e_temp_type.BLOCK)
		temp_update_block()
		
	// Switch to item
	if (type = e_temp_type.ITEM)
		temp_update_item()
	
	// Switch to shape
	if (type_is_shape(type))
		temp_update_shape()
}

// Switch to particles
if (bench_settings.type = e_temp_type.PARTICLE_SPAWNER)
	bench_update_particles_list()

with (bench_settings.preview)
{
	particle_spawner_clear()
	preview_reset_view()
	update = true
}

bench_clear()