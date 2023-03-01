/// CppSeparate void builder_thread_set_pos(Scope<obj_builder_thread>, IntType)
function builder_thread_set_pos(position)
{
	build_pos = position
	
	// Set block X/Y/Z of the thread from the position
	build_pos_x = build_pos mod build_size_x
	build_pos_y = (build_pos div build_size_x) mod build_size_y
	build_pos_z = build_pos div build_size_xy
}