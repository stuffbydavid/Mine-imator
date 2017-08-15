/// bench_click(type)
/// @arg type

with (bench_settings)
{
	type = argument0

	// Switch to character
	if (type = "char" && ds_list_find_index(mc_version.char_list, char_model_name) < 0)
	{
		char_model_name = "human"
		char_model_state = mc_version.model_name_map[?char_model_name].default_state
		temp_update_char_model_state_map()
		temp_update_char_model()
	}
	
	// Switch to special block
	if (type = "spblock" && ds_list_find_index(mc_version.special_block_list, char_model_name) < 0)
	{
		char_model_name = "chest"
		char_model_state = mc_version.model_name_map[?char_model_name].default_state
		temp_update_char_model_state_map()
		temp_update_char_model()
	}
	
	// Switch to block
	if (type = "block")
		temp_update_block()
		
	// Switch to item
	if (type = "item")
		temp_update_item()
	
	// Switch to shape
	if (type_is_shape(type))
		temp_update_shape()
}

// Switch to particles
if (bench_settings.type = "particles")
	bench_update_particles_list()

with (bench_settings.preview)
{
	particle_spawner_clear()
	preview_reset_view()
	update = true
}

bench_clear()