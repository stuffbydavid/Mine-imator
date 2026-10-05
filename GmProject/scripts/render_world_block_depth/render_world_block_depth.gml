/// @desc Renders a block in a depth pass.
/// @arg block
/// @arg diffuse
/// @arg [rotate]
/// @arg [size]

function render_world_block_depth(block, resdif, rotate = false, size = undefined)
{
	var vbuffer, tex, texprev, texani;
	vbuffer = block.block_vbuffer
	if (vbuffer = null)
		return 0

	resdif = res_eval(resdif)
	
	render_apply_res(resdif)

	tex = resdif.block_sheet_texture[e_block_sheet.STATIC16]
	texprev = tex
	if (resdif.block_sheet_texture[e_block_sheet.ANIMATED] != null)
		texani = resdif.block_sheet_texture[e_block_sheet.ANIMATED][block_texture_get_frame()]
	else
		texani = mc_res.block_sheet_texture[e_block_sheet.ANIMATED][block_texture_get_frame()]

	render_set_texture(tex)

	// Rotate by 90 degrees for legacy support
	if (rotate)
		matrix_world_multiply_pre(matrix_create(point3D(0, size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))

	#region Depth 0
	
	if (render_world_block_transparent != true)
	{
		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.STATIC16]))
			vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.STATIC16])

		for (var s = e_block_sheet.STATIC32; s < e_block_sheet.static_amount; s++)
		{
			var staticvbuffer = e_block_vbuffer.STATIC32 + s - e_block_sheet.STATIC32;
			if (vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, staticvbuffer]))
				continue

			var statictex = resdif.block_sheet_texture[s];
			if (statictex = null)
				statictex = mc_res.block_sheet_texture[s]

			if (statictex != texprev)
			{
				render_set_texture(statictex)
				texprev = statictex
			}

			vbuffer_render(vbuffer[e_block_depth.DEPTH0, staticvbuffer])
		}

		if (tex != texprev)
		{
			render_set_texture(tex)
			texprev = tex
		}

		for (var colorbuf = e_block_vbuffer.GRASS; colorbuf <= e_block_vbuffer.DRY_FOLIAGE; colorbuf++)
			if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, colorbuf]))
				vbuffer_render(vbuffer[e_block_depth.DEPTH0, colorbuf])

		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED]))
		{
			if (texani != texprev)
			{
				render_set_texture(texani)
				texprev = texani
			}
			vbuffer_render(vbuffer[e_block_depth.DEPTH0, e_block_vbuffer.ANIMATED])
		}
	}
	
	#endregion
	
	#region Depth 1

	if (render_world_block_transparent != null && !render_world_block_transparent)
		return 0

	if (tex != texprev)
	{
		render_set_texture(tex)
		texprev = tex
	}

	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.STATIC16]))
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.STATIC16])

	for (var vbuf = e_block_vbuffer.GRASS; vbuf <= e_block_vbuffer.LEAVES_MANGROVE; vbuf++)
		if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, vbuf]))
			vbuffer_render(vbuffer[e_block_depth.DEPTH1, vbuf])

	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED]))
	{
		if (texani != texprev)
		{
			render_set_texture(texani)
			texprev = texani
		}
		vbuffer_render(vbuffer[e_block_depth.DEPTH1, e_block_vbuffer.ANIMATED])
	}

	if (tex != texprev)
		render_set_texture(tex)

	#endregion

	#region Depth 2

	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.STATIC16]))
		vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.STATIC16])

	if (!vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED]))
	{
		render_set_texture(texani)
		vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.ANIMATED])
	}

	if (render_mode = e_render_mode.DEPTH && !vbuffer_is_empty(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.WATER]))
	{
		render_set_texture(texani)
		vbuffer_render(vbuffer[e_block_depth.DEPTH2, e_block_vbuffer.WATER])
	}

	#endregion
	
	return 0
}
