/// temp_update_block()
/// @desc Updates the block vbuffers of the given template.

block_vbuffer_start()

with (mc_builder)
{
	if (dev_mode_rotate_blocks)
		build_size = test(other.block_repeat_enable, vec3(other.block_repeat[Y], other.block_repeat[X], other.block_repeat[Z]), vec3(1))
	else
		build_size = test(other.block_repeat_enable, vec3(other.block_repeat[X], other.block_repeat[Y], other.block_repeat[Z]), vec3(1))
	builder_set_size()

	// Set blocks
	var block, stateid;
	block = mc_assets.block_name_map[?other.block_name]
	stateid = block_get_state_id(block, other.block_state)
	ds_grid_clear(block_obj, block)
	ds_grid_clear(block_state_id, stateid)
				
	// Set models
	for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
		for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
			for (build_pos_z = 0; build_pos_z < build_size_z; build_pos_z++)
				builder_set_model()
				
	// Generate
	for (build_pos_x = 0; build_pos_x < build_size_x; build_pos_x++)
		for (build_pos_y = 0; build_pos_y < build_size_y; build_pos_y++)
			for (build_pos_z = 0; build_pos_z < build_size_z; build_pos_z++)
				builder_generate()
}

block_vbuffer_done()