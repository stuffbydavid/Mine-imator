/// action_bench_model_state(value)
/// @arg value

var val, state;
val = argument0
state = menu_model_state.name

with (bench_settings)
{
	if (model_state_map[?state] = val) 
		return 0
		
	model_state_map[?state] = val
	model_state = state_vars_map_to_string(model_state_map)
	temp_update_model()
	
	preview.update = true
}