/// CppSeparate void builder_create_buffers(Scope<obj_builder>)
/// Allocate buffers (GML) or sections (C++)
function builder_create_buffers()
{
	block_obj = buffer_create(build_size_total * 2, buffer_fixed, 2)
	block_state_id = buffer_create(build_size_total * 2, buffer_fixed, 2)
	block_waterlogged = buffer_create(build_size_total, buffer_fixed, 1)
	
	build_size_sqrt = ceil(sqrt(build_size_total))
	block_render_model = ds_grid_create(build_size_sqrt, build_size_sqrt)
	block_render_model_multipart = ds_list_create()
	ds_list_add(block_render_model_multipart, array()) // Air
	
	ds_grid_clear(block_render_model, 0)
	
	// Fill with single block
	if (build_single_block != null)
	{
		buffer_fill(block_obj, 0, buffer_u16, build_single_block.block_id, build_size_total * 2)
		buffer_fill(block_state_id, 0, buffer_u16, build_single_stateid, build_size_total * 2)
		buffer_fill(block_waterlogged, 0, buffer_u8, false, build_size_total)
	}
}