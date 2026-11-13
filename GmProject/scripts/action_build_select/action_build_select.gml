function action_build_select(value, state = null)
{
	if (!place_build)
		return 0

	build_tool.build_selected = value
	
	if (value[0]) // Special block
	{
		build_type = e_tl_type.SPECIAL_BLOCK
		build_settings.type = e_temp_type.SPECIAL_BLOCK
		
		action_bench_model_name(value[1], state)
	}
	else // Block
	{
		build_type = e_tl_type.BLOCK
		build_settings.type = e_temp_type.BLOCK
		
		action_bench_block_name(value[1], state)
		
		with (build_settings)
			temp_update_rot_point()
	}

	place_pos = null
	place_view_pos = null
}
