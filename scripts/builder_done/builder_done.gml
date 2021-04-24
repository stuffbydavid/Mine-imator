/// builder_done()

function builder_done()
{
	buffer_delete(block_obj)
	buffer_delete(block_state_id)
	buffer_delete(block_waterlogged)
	ds_grid_destroy(block_render_model)
}
