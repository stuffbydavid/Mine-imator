/// action_bench_char_model_state(value)
/// @arg value

var val, state;
val = argument0
state = menu_model_state.name

with (bench_settings)
{
	if (char_model_state_map[?state] = val) 
		return 0
		
	char_model_state_map[?state] = val
	char_model_state = state_vars_map_to_string(char_model_state_map)
	temp_update_char_model()
	
	preview.update = true
}