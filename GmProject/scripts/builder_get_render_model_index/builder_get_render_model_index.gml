/// CppSeparate IntType builder_get_render_model_index(Scope<obj_builder_thread>, IntType, IntType, IntType)
/// @arg x
/// @arg y
/// @arg z

function builder_get_render_model_index(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size[X] + xx;
	return block_render_model[@pos]
}
