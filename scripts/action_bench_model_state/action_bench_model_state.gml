/// action_bench_model_state(value)
/// @arg value

var val, state;
val = argument0
state = menu_model_state.name

with (bench_settings)
{
	if (state_vars_get_value(model_state, state) = val) 
		return 0
		
	state_vars_set_value(model_state, state, val)
	temp_update_model()
	temp_update_model_part()
	temp_update_model_shape()
	model_shape_update_color()
	
	with (preview)
		update = true
}