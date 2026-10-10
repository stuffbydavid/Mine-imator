/// @desc Renders a block in a depth pass.
/// @arg block
/// @arg diffuse

function render_world_block_depth(block, resdif)
{
	if (block.block_vbuffer = null)
		return 0

	var tex, texprev, texani, active0, active1, active2, texready, basebound;

	resdif = res_eval(resdif)
	
	render_apply_res(resdif)

	tex = resdif.block_sheet_texture[e_block_sheet.STATIC16]
	texprev = tex
	texready = false

	active0 = e_block_depth.DEPTH0 * e_block_vbuffer.amount
	active1 = e_block_depth.DEPTH1 * e_block_vbuffer.amount
	active2 = e_block_depth.DEPTH2 * e_block_vbuffer.amount
	
	if (block.block_vbuffer_active[@ active0 + e_block_vbuffer.ANIMATED] ||
		block.block_vbuffer_active[@ active1 + e_block_vbuffer.ANIMATED] ||
		block.block_vbuffer_active[@ active2 + e_block_vbuffer.ANIMATED] ||
		(render_mode = e_render_mode.DEPTH && block.block_vbuffer_active[@ active2 + e_block_vbuffer.WATER]))
	{
		var frame = block_texture_get_frame();
		texani = resdif.block_sheet_animated_diffuse ? resdif.block_sheet_texture[e_block_sheet.ANIMATED][frame] : mc_res.block_sheet_texture[e_block_sheet.ANIMATED][frame]
	}

	#region Depth 0
	
	if (render_world_block_transparent != true)
	{
		if (block.block_vbuffer_active[@ active0 + e_block_vbuffer.STATIC16])
		{
			render_set_texture(resdif, tex)
			texready = true
			vbuffer_render(block.block_vbuffer[@ active0 + e_block_vbuffer.STATIC16])
		}

		for (var s = e_block_sheet.STATIC32; s < e_block_sheet.static_amount; s++)
		{
			var staticvbuffer = e_block_vbuffer.STATIC32 + s - e_block_sheet.STATIC32;
			if (!block.block_vbuffer_active[@ active0 + staticvbuffer])
				continue

			var statictex = resdif.block_sheet_texture[s];
			if (statictex = null)
				statictex = mc_res.block_sheet_texture[s]

			if (!texready || statictex != texprev)
			{
				render_set_texture(resdif, statictex)
				texprev = statictex
			}

			texready = true
			vbuffer_render(block.block_vbuffer[@ active0 + staticvbuffer])
		}

		if (block.block_vbuffer_active[@ active0 + e_block_vbuffer.GRASS] ||
			block.block_vbuffer_active[@ active0 + e_block_vbuffer.FOLIAGE] ||
			block.block_vbuffer_active[@ active0 + e_block_vbuffer.DRY_FOLIAGE])
		{
			if (!texready || tex != texprev)
			{
				render_set_texture(resdif, tex)
				texprev = tex
			}
			
			texready = true
		}

		for (var colorbuf = e_block_vbuffer.GRASS; colorbuf <= e_block_vbuffer.DRY_FOLIAGE; colorbuf++)
			if (block.block_vbuffer_active[@ active0 + colorbuf])
				vbuffer_render(block.block_vbuffer[@ active0 + colorbuf])

		if (block.block_vbuffer_active[@ active0 + e_block_vbuffer.ANIMATED])
		{
			if (!texready || texani != texprev)
			{
				render_set_texture(resdif, texani)
				texprev = texani
			}
			
			texready = true
			vbuffer_render(block.block_vbuffer[@ active0 + e_block_vbuffer.ANIMATED])
		}
	}
	
	#endregion
	
	#region Depth 1

	if (render_world_block_transparent != null && !render_world_block_transparent)
		return 0

	if (block.block_vbuffer_active[@ active1 + e_block_vbuffer.STATIC16])
	{
		if (!texready || tex != texprev)
		{
			render_set_texture(resdif, tex)
			texprev = tex
		}
		
		texready = true
		vbuffer_render(block.block_vbuffer[@ active1 + e_block_vbuffer.STATIC16])
	}

	basebound = false
	
	for (var vbuf = e_block_vbuffer.GRASS; vbuf <= e_block_vbuffer.LEAVES_MANGROVE; vbuf++)
	{
		if (!block.block_vbuffer_active[@ active1 + vbuf])
			continue
		
		if (!basebound)
		{
			if (!texready || tex != texprev)
			{
				render_set_texture(resdif, tex)
				texprev = tex
			}
			
			texready = true
			basebound = true
		}
		
		vbuffer_render(block.block_vbuffer[@ active1 + vbuf])
	}

	if (block.block_vbuffer_active[@ active1 + e_block_vbuffer.ANIMATED])
	{
		if (!texready || texani != texprev)
		{
			render_set_texture(resdif, texani)
			texprev = texani
		}
		
		texready = true
		vbuffer_render(block.block_vbuffer[@ active1 + e_block_vbuffer.ANIMATED])
	}

	#endregion

	#region Depth 2

	if (block.block_vbuffer_active[@ active2 + e_block_vbuffer.STATIC16])
	{
		if (!texready || tex != texprev)
		{
			render_set_texture(resdif, tex)
			texprev = tex
		}
		
		texready = true
		vbuffer_render(block.block_vbuffer[@ active2 + e_block_vbuffer.STATIC16])
	}

	if (block.block_vbuffer_active[@ active2 + e_block_vbuffer.ANIMATED])
	{
		render_set_texture(resdif, texani)
		vbuffer_render(block.block_vbuffer[@ active2 + e_block_vbuffer.ANIMATED])
	}

	if (render_mode = e_render_mode.DEPTH && block.block_vbuffer_active[@ active2 + e_block_vbuffer.WATER])
	{
		render_set_texture(resdif, texani)
		vbuffer_render(block.block_vbuffer[@ active2 + e_block_vbuffer.WATER])
	}

	#endregion
	
	return 0
}
