/// CppSeparate IntType builder_get_block(Scope<obj_builder_thread>, IntType, IntType, IntType)
function builder_get_block(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	var obj = buffer_peek(block_obj, pos * 2, buffer_u16);
	return block_objs[obj];
}

/// CppSeparate IntType builder_get_state_id(Scope<obj_builder_thread>, IntType, IntType, IntType)
function builder_get_state_id(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	return buffer_peek(block_state_id, pos * 2, buffer_u16)
}

/// CppSeparate IntType builder_get_waterlogged(Scope<obj_builder_thread>, IntType, IntType, IntType)
function builder_get_waterlogged(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	return buffer_peek(block_waterlogged, pos, buffer_u8)
}

/// CppSeparate IntType builder_get_render_model_index(Scope<obj_builder_thread>, IntType, IntType, IntType)
function builder_get_render_model_index(xx, yy, zz)
{
	var pos = zz * build_size_xy + yy * build_size_x + xx;
	return ds_grid_get(block_render_model, pos div build_size_sqrt, pos mod build_size_sqrt)
}

/// CppSeparate IntType builder_get_render_model(Scope<obj_builder_thread>, IntType, IntType, IntType)
/// Returns a single (non-multipart) render model instance
function builder_get_render_model(xx, yy, zz)
{
	var index = builder_get_render_model_index(xx, yy, zz);
	if (index <= 0)
		return null
	
	return block_rendermodels[index];
}

/// CppSeparate ArrType builder_get_render_model_multipart(IntType, IntType, IntType, IntType)
/// Returns an array of models at an index
function builder_get_render_model_multipart(xx, yy, zz, index)
{
	return mc_builder.block_render_model_multipart[|index];
}