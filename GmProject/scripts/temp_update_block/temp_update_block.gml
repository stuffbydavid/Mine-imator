/// temp_update_block()
/// @desc Updates the block vbuffers of the given template.
function temp_update_block() {

	block_vbuffer_start()

	with (mc_builder)
	{
		build_single_block = mc_assets.block_name_map[?other.block_name]
		build_single_stateid = block_get_state_id(build_single_block, other.block_state)
		
		if (other.block_repeat_enable)
		{
			build_size_x = other.block_repeat[Y]
			build_size_y = other.block_repeat[X]
			build_size_z = other.block_repeat[Z]
		}
		else
		{
			build_size_x = 1
			build_size_y = 1
			build_size_z = 1
		}
		
		build_randomize = other.block_randomize
		
		builder_start()
		builder_spawn_threads(1)
		with (thread_list[|0])
		{
			// Set models
			for (var p = 0; p < build_size_total; p++)
			{
				builder_thread_set_pos(p)
				builder_set_model()
			}
		}
		builder_combine_threads()
		builder_spawn_threads(1)
		with (thread_list[|0])
		{
			// Generate
			for (var p = 0; p < build_size_total; p++)
			{
				builder_thread_set_pos(p)
				builder_generate()
			}
		}
		builder_combine_threads()
		builder_done()
		
		build_randomize = false
		
		build_single_block = null
		build_single_stateid = 0
	}

	block_vbuffer_done()

}
