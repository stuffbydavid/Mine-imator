/// CppSeparate void builder_set_render_model(Scope<obj_builder_thread>, IntType, IntType, IntType, IntType)

function builder_set_render_model(xx, yy, zz, val)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	ds_grid_set(block_render_model, pos div build_size_sqrt, pos mod build_size_sqrt, val)
}
