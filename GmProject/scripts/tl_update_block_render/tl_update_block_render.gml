function tl_update_block_render()
{
	var res = tl_get_block_res();
	if (res != null && res.block_vbuffer != null)
		block_vbuffer_transparent_render = (res.block_vbuffer_depth_active[e_block_depth.DEPTH1] || res.block_vbuffer_depth_active[e_block_depth.DEPTH2])
	else
		block_vbuffer_transparent_render = false
}