function block_mesh_event_create()
{
	block_vbuffer = []
	block_vbuffer_active = []
	block_vbuffer_depth_active = []
	block_vbuffer_render_order = []
	block_vbuffer_render_offsets = array_create(e_block_depth.amount + 1, 0)
}
