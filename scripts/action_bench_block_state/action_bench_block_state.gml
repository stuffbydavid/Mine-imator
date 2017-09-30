/// action_bench_block_state(value)
/// @arg value

var val, state;
val = argument0
state = menu_block_state.name

with (bench_settings)
{
	if (state_vars_get_value(block_state, state) = val) 
		return 0
		
	state_vars_set_value(block_state, state, val)
	temp_update_block()
	
	preview.update = true
}