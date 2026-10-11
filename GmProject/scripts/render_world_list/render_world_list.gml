/// @desc Renders the list of a depth sign, followed by transparent block meshes.

function render_world_list(depthsign)
{
	var list, listsize;

	// Select list
	if (render_mode = e_render_mode.PLACE_PARENT)
		list = render_place_parent_list
	else
		list = render_list[depthsign + 1]
	
	listsize = ds_list_size(list)
	if (listsize = 0)
		return 0
	
	// Depth passes
	if (render_depth_pass)
	{
		for (var i = 0; i < listsize; i++)
			with (list[|i])
				render_world_tl()
		
		return 0
	}
	
	var transpblocks, i;
	transpblocks = render_block_transparent_list[depthsign + 1]
	ds_list_clear(transpblocks)

	for (i = 0; i < listsize; i++)
	{
		with (list[|i])
		{
			render_world_tl()
			
			// Find visible transparent block meshes
			if (!block_vbuffer_transparent_render || !render_visible || (!app.place_tl_render && (placed || parent_is_placed)))
				continue
				
			if (type = e_tl_type.PARTICLE_SPAWNER && !render_particles)
				continue
				
			ds_list_add(transpblocks, id)
		}

	}

	if (ds_list_size(transpblocks) = 0)
		return 0
	
	// Render transparent blocks, turning off texture filtering if needed
	var filterprev = gpu_get_tex_mip_bias();
	
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
		gpu_set_tex_mip_bias(-16)
	
	render_world_block_transparent = true
	
	for (i = 0; i < ds_list_size(transpblocks); i++)
		with (transpblocks[|i])
			render_world_tl()
	
	render_world_block_transparent = false
	
	gpu_set_tex_mip_bias(filterprev)
}
