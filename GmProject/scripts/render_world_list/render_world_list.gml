/// @desc Renders a range of depth signs, followed by transparent block meshes.

function render_world_list(depthsign)
{
	var listsize, startindex, endindex, filterprev, i;
	listsize = ds_list_size(render_list)
	
	startindex = 0
	while (startindex < listsize && sign(render_list[|startindex].depth) < depthsign)
		startindex++
	
	endindex = startindex
	while (endindex < listsize && sign(render_list[|endindex].depth) <= depthsign)
		endindex++
	
	if (endindex = startindex)
		return 0
	
	for (i = startindex; i < endindex; i++)
		with (render_list[|i])
			render_world_tl()
	
	filterprev = gpu_get_tex_mip_bias()
	
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
		gpu_set_tex_mip_bias(-16)
	
	render_world_block_transparent = true
	
	for (i = startindex; i < endindex; i++)
		with (render_list[|i])
			render_world_tl()
	
	render_world_block_transparent = false
	
	gpu_set_tex_mip_bias(filterprev)
}
