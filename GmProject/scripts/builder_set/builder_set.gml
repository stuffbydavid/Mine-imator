/// CppSeparate void builder_set_state_id(Scope<obj_builder_thread>, IntType, IntType, IntType, IntType)
function builder_set_state_id(xx, yy, zz, val)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	buffer_poke(block_state_id, pos * 2, buffer_u16, val)
}

/// CppSeparate void builder_set_render_model(Scope<obj_builder_thread>, IntType, IntType, IntType, IntType)
function builder_set_render_model(xx, yy, zz, val)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	ds_grid_set(block_render_model, pos div build_size_sqrt, pos mod build_size_sqrt, val)
}

/// CppSeparate IntType builder_add_render_model_multi_part(Scope<obj_builder_thread>, IntType, IntType, IntType, ArrType)
/// Adds a multipart model array (if unique) and returns the index
function builder_add_render_model_multi_part(xx, yy, zz, arr)
{
	var size = ds_list_size(mc_builder.block_render_model_multipart);
	var index;
	for (index = size - 1; index >= 1; index--)
	{
		var othermodel = mc_builder.block_render_model_multipart[|index];
		if (array_equals(othermodel, arr))
			break;
	}
	
	if (index == 0)
	{
		index = size
		ds_list_add(mc_builder.block_render_model_multipart, arr)
	}
	
	builder_set_render_model(xx, yy, zz, -index) // negative number to use multipart grid
}