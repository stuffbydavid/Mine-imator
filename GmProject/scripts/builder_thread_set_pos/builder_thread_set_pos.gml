/// CppSeparate void builder_thread_set_pos(Scope<obj_builder_thread>, IntType)

function builder_thread_set_pos(position)
{
	build_pos_index = position
	
	// Set block X/Y/Z of the thread from the position
	build_pos[X] = build_pos_index mod build_size[X]
	build_pos[Y] = (build_pos_index div build_size[X]) mod build_size[Y]
	build_pos[Z] = build_pos_index div build_size_xy

	if (array_length(block_meshes) > 0)
	{
		var meshindex = block_mesh_get_index(build_pos[X], build_pos[Y], build_pos[Z], block_meshes_num[X], block_meshes_num[Y]);
		block_mesh = block_meshes[meshindex]
	}
}
