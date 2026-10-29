function block_mesh_event_create()
{
	block_vbuffer = array_create(e_block_depth.amount * e_block_vbuffer.amount, null)
	block_vbuffer_active = array_create(e_block_depth.amount * e_block_vbuffer.amount, false)
	block_vbuffer_depth_active = array_create(e_block_depth.amount, false)
	block_vbuffer_render_order = []
	block_vbuffer_render_offsets = array_create(e_block_depth.amount + 1, 0)

	block_palette_buffer = null
	block_grid_size = vec3(0)
	block_grid_buffer = null
}
