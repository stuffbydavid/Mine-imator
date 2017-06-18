/// bench_click(type)
/// @arg type

with (bench_settings)
{
	type = argument0
		
	// Switch to character / body part from special block TODO!
	/*if ((bench_settings.type = "char" || bench_settings.type = "bodypart") && bench_settings.char_model.index >= chest.index) 
	{
		bench_settings.char_model = char_model_map[?"human"]
		bench_settings.char_skin = res_def
		bench_settings.char_bodypart = 0
	}

	// Switch from character->special block
	if (bench_settings.type = "spblock" && bench_settings.char_model.index < chest.index) 
	{
		bench_settings.char_model = chest
		bench_settings.char_skin = res_def
	}*/
	
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