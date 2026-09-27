/// CppSeparate IntType builder_get_render_model_index(Scope<obj_builder_thread>, IntType, IntType, IntType)

function builder_get_render_model_index(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	return ds_grid_get(block_render_model, pos div build_size_sqrt, pos mod build_size_sqrt)
}
