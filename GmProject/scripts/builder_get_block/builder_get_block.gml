/// CppSeparate IntType builder_get_block(Scope<obj_builder_thread>, IntType, IntType, IntType)

function builder_get_block(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	var obj = buffer_peek(block_obj, pos * 2, buffer_u16);
	return block_objs[obj];
}
