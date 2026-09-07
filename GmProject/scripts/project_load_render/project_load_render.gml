/// project_load_render(map)

function project_load_render(map)
{
	if (!ds_map_valid(map))
		return 0
		
	var preset = new_obj(obj_render_preset);
	with (preset)
		render_preset_load_settings(map)
	
	// TODO find a suitable preset
	
	instance_destroy(preset)
	
}