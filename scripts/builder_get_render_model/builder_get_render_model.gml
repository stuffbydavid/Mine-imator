/// builder_get_render_model(x, y, z)
/// @arg x
/// @arg y
/// @arg z
/// @arg val

function builder_get_render_model(xx, yy, zz)
{
	var ind = builder_get_index(xx, yy, zz);
	
	return ds_grid_get(block_render_model, ind div build_size_sqrt, ind mod build_size_sqrt)
}
