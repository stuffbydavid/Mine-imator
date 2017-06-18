/// temp_update_block()
/// @desc Updates the block vbuffers of the given template.

block_vbuffer_start()

with (mc_builder)
{
	build_size = test(other.repeat_toggle, vec3(other.repeat_x, other.repeat_y, other.repeat_z), vec3(1, 1, 1))
	
	// Set blocks
	array3D_fill(block_id, build_size, other.block_id)
	array3D_fill(block_data, build_size, other.block_data)
				
	// Set models
	for (build_pos[X] = 0; build_pos[X] < build_size[X]; build_pos[X]++)
		for (build_pos[Y] = 0; build_pos[Y] < build_size[Y]; build_pos[Y]++)
			for (build_pos[Z] = 0; build_pos[Z] < build_size[Z]; build_pos[Z]++)
				builder_set_models()
				
	// Generate
	for (build_pos[X] = 0; build_pos[X] < build_size[X]; build_pos[X]++)
		for (build_pos[Y] = 0; build_pos[Y] < build_size[Y]; build_pos[Y]++)
			for (build_pos[Z] = 0; build_pos[Z] < build_size[Z]; build_pos[Z]++)
				builder_generate()
}

block_vbuffer_done()