/// CppSeparate IntType builder_get_waterlogged(Scope<obj_builder_thread>, IntType, IntType, IntType)

function builder_get_waterlogged(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	return buffer_peek(block_waterlogged, pos, buffer_u8)
}
