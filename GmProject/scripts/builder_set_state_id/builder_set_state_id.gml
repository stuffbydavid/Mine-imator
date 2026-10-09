/// CppSeparate void builder_set_state_id(Scope<obj_builder_thread>, IntType, IntType, IntType, IntType)
/// @arg x
/// @arg y
/// @arg z
/// @arg value

function builder_set_state_id(xx, yy, zz, val)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	buffer_poke(block_state_id, pos * 2, buffer_u16, val)
}
