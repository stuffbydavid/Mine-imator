/// action_bench_block_state(value)
/// @arg value

var val, state;
val = argument0
state = menu_block_state.name

with (bench_settings)
{
	if (block_state_map[?state] = val) 
		return 0
		
	block_state_map[?state] = val
	block_state = state_vars_map_to_string(block_state_map)
	temp_update_block()
	
	preview.update = true
}