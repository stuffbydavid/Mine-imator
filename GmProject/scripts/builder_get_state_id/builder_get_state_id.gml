/// CppSeparate IntType builder_get_state_id(Scope<obj_builder_thread>, IntType, IntType, IntType)
/// @arg x
/// @arg y
/// @arg z

function builder_get_state_id(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	return buffer_peek(block_state_id, pos * 2, buffer_u16)
}
