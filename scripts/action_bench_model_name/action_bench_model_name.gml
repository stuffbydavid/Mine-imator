/// action_bench_model_name(name)
/// @arg name

with (bench_settings)
{
	if (model_name = argument0)
		return 0
		
	model_name = argument0
	model_state = mc_version.model_name_map[?model_name].default_state
	temp_update_model_state_map()
	temp_update_model()
	
	//bodypart = min(bench_settings.char_art, bench_settings.char_model_amount - 1)
	preview.update = true
}