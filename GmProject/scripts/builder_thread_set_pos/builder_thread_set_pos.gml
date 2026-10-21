/// CppSeparate void builder_thread_set_pos(Scope<obj_builder_thread>, IntType)

function builder_thread_set_pos(position)
{
	build_pos_index = position
	
	// Set block X/Y/Z of the thread from the position
	build_pos[X] = build_pos_index mod build_size[X]
	build_pos[Y] = (build_pos_index div build_size[X]) mod build_size[Y]
	build_pos[Z] = build_pos_index div build_size_xy
}
