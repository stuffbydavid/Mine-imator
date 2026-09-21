/// action_build_select(value)
/// @arg value

function action_build_select(value)
{
	if (!place_build)
		return 0

	build_mode.build_selected = value
	
	if (value[0]) // Special block
	{
		build_type = e_tl_type.SPECIAL_BLOCK
		build_settings.type = e_tl_type.SPECIAL_BLOCK
		action_bench_model_name(value[1])
	}
	else // Block
	{
		build_type = e_tl_type.BLOCK
		build_settings.type = e_tl_type.BLOCK
		action_bench_block_name(value[1])
		with (build_settings)
			temp_update_rot_point()
	}

	place_pos = null
	place_view_pos = null
}
