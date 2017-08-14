/// action_bench_char_model_name(char_model_name)
/// @arg model

with (bench_settings)
{
	if (char_model_name = argument0)
		return 0
		
	char_model_name = argument0
	char_model_state = mc_version.model_name_map[?char_model_name].default_state
	temp_update_char_model_state_map()
	temp_update_char_model()
	
	//char_bodypart = min(bench_settings.char_bodypart, bench_settings.char_model.part_amount - 1)
	preview.update = true
}