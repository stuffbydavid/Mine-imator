/// @desc Updates the vbuffer to be used for fancy/poor clouds.

function env_sky_update_clouds()
{
	var res, tex, texwid, texhei, texsize, hei, cloudsize;
	res = res_eval(env_sky_clouds_tex)
	
	if (!res.ready)
		return 0
	
	tex = ((res.type = e_res_type.PACK) ? res.clouds_texture : res.texture)
	texwid = texture_width(tex)
	texhei = texture_height(tex)
	texsize = max(texwid, texhei)
	hei = 0

	// Store cloud shading in the shared color index, including the faded alpha endpoints
	var faded, darkindex, lightindex, topindex, bottomindex, subsurface;
	faded = (env_sky_clouds_mode = "faded")
	
	if (faded)
	{
		darkindex = 0
		lightindex = 0
		topindex = e_color_palette.CLOUDS_FADED + 1
		bottomindex = 0
	}
	else
	{
		darkindex = e_color_palette.CLOUDS_SIDES_DARK + 1
		lightindex = e_color_palette.CLOUDS_SIDES_LIGHT + 1
		topindex = e_color_palette.CLOUDS_TOP + 1

		if (env_sky_clouds_mode = "flat")
			bottomindex = topindex
		else
			bottomindex = e_color_palette.CLOUDS_BOTTOM + 1
	}

	subsurface = vertex_subsurface_color_index
	
	// Clean up
	if (env_sky_clouds_vbuffer)
		vbuffer_destroy(env_sky_clouds_vbuffer)
	
	env_sky_clouds_vbuffer = vbuffer_start()
	cloudsize = env_sky_clouds_size_xy * 256
	
	if (env_sky_clouds_mode != "flat")
	{
		var surf = surface_create(texwid, texhei);
		surface_set_target(surf)
		{
			draw_clear_alpha(c_black, 0)
			draw_texture(tex, 0, 0)
		}
		surface_reset_target()
		
		buffer_current = buffer_create(texwid * texhei * 4, buffer_fixed, 4)
		buffer_get_surface(buffer_current, surf, 0)
		buffer_seek(buffer_current, buffer_seek_start, 0)
		
		// Store pixels
		var hascolor;
		for (var py = 0; py < texhei; py++)
			for (var px = 0; px < texwid; px++)
				hascolor[px, py] = (buffer_read_int_uns() >> 24 = 255)
		
		buffer_delete(buffer_current)
		surface_free(surf)
		
		var pw, ph, blockw, blockh;
		pw = 1 / texwid
		ph = 1 / texhei
		blockw = cloudsize / texwid
		blockh = cloudsize / texhei
		hei = env_sky_clouds_size_z
		
		for (var xx = 0; xx < texwid; xx++)
		{
			for (var yy = 0; yy < texhei; yy++)
			{
				var vx, vy, tx, ty;
				
				if (!hascolor[xx, yy])
					continue
				
				vx = xx * blockw
				vy = yy * blockh
				tx = xx * pw
				ty = yy * ph
				
				if (!hascolor[(xx + 1) mod texwid, yy])
				{
					vertex_subsurface_color_index = darkindex * 2
					
					vertex_add_real(vx + blockw, vy + blockh, 0, 1, 0, 0, tx, ty)
					
					if (faded)
						vertex_subsurface_color_index = topindex * 2
					else
						vertex_subsurface_color_index = darkindex * 2
					
					vertex_add_real(vx + blockw, vy + blockh, hei, 1, 0, 0, tx, ty + ph)
					vertex_add_real(vx + blockw, vy, hei, 1, 0, 0, tx + pw, ty + ph)
					vertex_add_real(vx + blockw, vy, hei, 1, 0, 0, tx + pw, ty + ph)
					
					vertex_subsurface_color_index = darkindex * 2
					
					vertex_add_real(vx + blockw, vy, 0, 1, 0, 0, tx + pw, ty)
					vertex_add_real(vx + blockw, vy + blockh, 0, 1, 0, 0, tx, ty)
				}
				
				if (!hascolor[mod_fix(xx - 1, texwid), yy])
				{
					vertex_subsurface_color_index = darkindex * 2
					
					vertex_add_real(vx, vy, 0, -1, 0, 0, tx, ty)
					
					if (faded)
						vertex_subsurface_color_index = topindex * 2
					else
						vertex_subsurface_color_index = darkindex * 2
					
					vertex_add_real(vx, vy, hei, -1, 0, 0, tx, ty + ph)
					vertex_add_real(vx, vy + blockh, hei, -1, 0, 0, tx + pw, ty + ph)
					vertex_add_real(vx, vy + blockh, hei, -1, 0, 0, tx + pw, ty + ph)
					
					vertex_subsurface_color_index = darkindex * 2
					
					vertex_add_real(vx, vy + blockh, 0, -1, 0, 0, tx + pw, ty)
					vertex_add_real(vx, vy, 0, -1, 0, 0, tx, ty)
				}
				
				if (!hascolor[xx, (yy + 1) mod texhei])
				{
					vertex_subsurface_color_index = lightindex * 2
					
					vertex_add_real(vx, vy + blockh, 0, 0, 1, 0, tx, ty)
					
					if (faded)
						vertex_subsurface_color_index = topindex * 2
					else
						vertex_subsurface_color_index = lightindex * 2
					
					vertex_add_real(vx, vy + blockh, hei, 0, 1, 0, tx, ty + ph)
					vertex_add_real(vx + blockw, vy + blockh, hei, 0, 1, 0, tx + pw, ty + ph)
					vertex_add_real(vx + blockw, vy + blockh, hei, 0, 1, 0, tx + pw, ty + ph)
					
					vertex_subsurface_color_index = lightindex * 2
					
					vertex_add_real(vx + blockw, vy + blockh, 0, 0, 1, 0, tx + pw, ty)
					vertex_add_real(vx, vy + blockh, 0, 0, 1, 0, tx, ty)
				}
				
				if (!hascolor[xx, mod_fix(yy - 1, texhei)])
				{
					vertex_subsurface_color_index = lightindex * 2
					
					vertex_add_real(vx + blockw, vy, 0, 0, -1, 0, tx, ty)
					
					if (faded)
						vertex_subsurface_color_index = topindex * 2
					else
						vertex_subsurface_color_index = lightindex * 2
					
					vertex_add_real(vx + blockw, vy, hei, 0, -1, 0, tx, ty + ph)
					vertex_add_real(vx, vy, hei, 0, -1, 0, tx + pw, ty + ph)
					vertex_add_real(vx, vy, hei, 0, -1, 0, tx + pw, ty + ph)
					
					vertex_subsurface_color_index = lightindex * 2
					
					vertex_add_real(vx, vy, 0, 0, -1, 0, tx + pw, ty)
					vertex_add_real(vx + blockw, vy, 0, 0, -1, 0, tx, ty)
				}
			}
		}
	}
	
	vertex_subsurface_color_index = bottomindex * 2
	
	vertex_add_real(0, 0, 0, 0, 0, -1, 0, 0)
	vertex_add_real(0, cloudsize, 0, 0, 0, -1, 0, 1)
	vertex_add_real(cloudsize, cloudsize, 0, 0, 0, -1, 1, 1)
	vertex_add_real(cloudsize, cloudsize, 0, 0, 0, -1, 1, 1)
	vertex_add_real(cloudsize, 0, 0, 0, 0, -1, 1, 0)
	vertex_add_real(0, 0, 0, 0, 0, -1, 0, 0)
	
	if (env_sky_clouds_mode != "faded")
	{
		vertex_subsurface_color_index = topindex * 2
		
		vertex_add_real(0, 0, hei, 0, 0, 1, 0, 0)
		vertex_add_real(cloudsize, 0, hei, 0, 0, 1, 1, 0)
		vertex_add_real(cloudsize, cloudsize, hei, 0, 0, 1, 1, 1)
		vertex_add_real(cloudsize, cloudsize, hei, 0, 0, 1, 1, 1)
		vertex_add_real(0, cloudsize, hei, 0, 0, 1, 0, 1)
		vertex_add_real(0, 0, hei, 0, 0, 1, 0, 0)
	}
	
	vbuffer_done()
	
	vertex_subsurface_color_index = subsurface
}
