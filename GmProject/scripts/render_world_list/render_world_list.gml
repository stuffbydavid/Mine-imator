/// @desc Renders a range of depth signs, followed by transparent block meshes.

function render_world_list(depthsign)
{
	var startindex, endindex, transpblocks, filterprev, i;
	startindex = render_list_depth_bounds[depthsign + 1]
	endindex = render_list_depth_bounds[depthsign + 2]
	
	if (endindex = startindex)
		return 0
	
	transpblocks = render_block_transparent_list[depthsign + 1]
	ds_list_clear(transpblocks)

	for (i = startindex; i < endindex; i++)
	{
		with (render_list[|i])
		{
			render_world_tl()
			
			if (!render_visible || (!app.place_tl_render && (placed || parent_is_placed)))
				continue
				
			// Find transparent block meshes
			var res = tl_get_block_res();

			if (res != null && res.block_vbuffer != null &&
				(res.block_vbuffer_depth_active[e_block_depth.DEPTH1] || res.block_vbuffer_depth_active[e_block_depth.DEPTH2]))
				ds_list_add(transpblocks, id)
		}

	}

	if (ds_list_size(transpblocks) = 0)
		return 0
	
	// Render transparent blocks, turning off texture filtering if needed
	filterprev = gpu_get_tex_mip_bias()
	
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
		gpu_set_tex_mip_bias(-16)
	
	render_world_block_transparent = true
	
	for (i = 0; i < ds_list_size(transpblocks); i++)
		with (transpblocks[|i])
			render_world_tl()
	
	render_world_block_transparent = false
	
	gpu_set_tex_mip_bias(filterprev)
}
