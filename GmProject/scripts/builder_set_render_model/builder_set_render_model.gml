/// CppSeparate void builder_set_render_model(Scope<obj_builder_thread>, IntType, IntType, IntType, IntType)
/// @arg x
/// @arg y
/// @arg z
/// @arg value

function builder_set_render_model(xx, yy, zz, val)
{
	var pos = zz * build_size_xy + yy * build_size[X] + xx;
	block_render_model[@pos] = val
}
