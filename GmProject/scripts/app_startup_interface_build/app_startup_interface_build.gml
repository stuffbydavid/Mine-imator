/// app_startup_interface_build()

function app_startup_interface_build()
{
	with (build_settings)
	{
		temp_event_create()
		
		temp = id
		type = e_temp_type.BLOCK
		block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
		
		temp_update_rot_point()
		preview = null
	}
}
