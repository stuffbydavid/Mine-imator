function action_bench_block_state(value)
{
	var state, settings;
	state = menu_block_state.name
	settings = place_build ? build_settings : bench_settings
	
	with (settings)
	{
		if (state_vars_get_value(block_state, state) = value)
			return 0
		
		state_vars_set_value(block_state, state, value)
		
		temp_update_block()
		
		if (preview != null)
			preview.update = true
	}
}
