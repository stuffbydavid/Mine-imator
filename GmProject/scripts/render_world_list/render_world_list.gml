/// @desc Renders the given list of timeline objects, followed by transparent block meshes.

function render_world_list(list)
{
	if (ds_list_size(list) = 0)
		return 0
	
	var transpblocks = false;
	for (var i = 0; i < ds_list_size(list); i++)
	{
		with (list[|i])
		{
			if (!render_visible)
				continue
				
			render_world_tl()
			
			// Find visible transparent block meshes
			if (render_world_blocks_transparent = null || !render_blocks_transparent)
				continue
				
			if (type = e_tl_type.PARTICLE_SPAWNER && !render_particles)
				continue
				
			if (!transpblocks)
			{
				ds_list_clear(render_block_transparent_list)
				transpblocks = true
			}
			
			ds_list_add(render_block_transparent_list, id)
		}
	}

	if (!transpblocks)
		return 0
	
	// Render transparent blocks, turning off texture filtering if needed
	var filterprev = gpu_get_tex_mip_bias();
	
	if (app.project_render_texture_filtering && !app.project_render_transparent_block_texture_filtering)
		gpu_set_tex_mip_bias(-16)
	
	render_world_blocks_transparent = true
	
	for (var i = 0; i < ds_list_size(render_block_transparent_list); i++)
		with (render_block_transparent_list[|i])
			render_world_tl()
	
	render_world_blocks_transparent = false
	
	gpu_set_tex_mip_bias(filterprev)
}
