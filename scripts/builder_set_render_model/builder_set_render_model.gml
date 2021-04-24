/// builder_set_render_model(x, y, z, value)
/// @arg x
/// @arg y
/// @arg z
/// @arg val

function builder_set_render_model(xx, yy, zz, val)
{
	var ind = builder_get_index(xx, yy, zz);
	
	ds_grid_set(block_render_model, ind div build_size_sqrt, ind mod build_size_sqrt, val)
}
