/// @desc Updates the vbuffer to be used for fancy/poor clouds.

function env_sky_update_clouds()
{
	var res, tex, texwid, texhei, texsize, hei, topalpha, cloudsize, col, colsidesdark, colsideslight, coltop, colbottom;
	res = res_eval(env_sky_clouds_tex)
	
	if (!res.ready)
		return 0
	
	tex = ((res.type = e_res_type.PACK) ? res.clouds_texture : res.texture)
	texwid = texture_width(tex)
	texhei = texture_height(tex)
	texsize = max(texwid, texhei)
	hei = 0
	
	if (env_sky_clouds_mode = "faded")
	{
		// Story Mode in-game tint: make_color_rgb(216, 230, 255)
		colsidesdark = c_white
		colsideslight = c_white
		coltop = c_white
		colbottom = c_white
		topalpha = 0
	}
	else
	{
		colsidesdark = c_clouds_sidesdark
		colsideslight = c_clouds_sideslight
		coltop = c_clouds_top
		colbottom = c_clouds_bottom
		topalpha = 1
	}
	
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
					vertex_rgb = colsidesdark
					vertex_alpha = 1
					vertex_add_real(vx + blockw, vy + blockh, 0, 1, 0, 0, tx, ty)
					
					vertex_alpha = topalpha
					vertex_add_real(vx + blockw, vy + blockh, hei, 1, 0, 0, tx, ty + ph)
					vertex_add_real(vx + blockw, vy, hei, 1, 0, 0, tx + pw, ty + ph)
					vertex_add_real(vx + blockw, vy, hei, 1, 0, 0, tx + pw, ty + ph)
					
					vertex_alpha = 1
					vertex_add_real(vx + blockw, vy, 0, 1, 0, 0, tx + pw, ty)
					vertex_add_real(vx + blockw, vy + blockh, 0, 1, 0, 0, tx, ty)
				}
				
				if (!hascolor[mod_fix(xx - 1, texwid), yy])
				{
					vertex_rgb = colsidesdark
					vertex_alpha = 1
					vertex_add_real(vx, vy, 0, -1, 0, 0, tx, ty)
					
					vertex_alpha = topalpha
					vertex_add_real(vx, vy, hei, -1, 0, 0, tx, ty + ph)
					vertex_add_real(vx, vy + blockh, hei, -1, 0, 0, tx + pw, ty + ph)
					vertex_add_real(vx, vy + blockh, hei, -1, 0, 0, tx + pw, ty + ph)
					
					vertex_alpha = 1
					vertex_add_real(vx, vy + blockh, 0, -1, 0, 0, tx + pw, ty)
					vertex_add_real(vx, vy, 0, -1, 0, 0, tx, ty)
				}
				
				if (!hascolor[xx, (yy + 1) mod texhei])
				{
					vertex_rgb = colsideslight
					vertex_alpha = 1
					vertex_add_real(vx, vy + blockh, 0, 0, 1, 0, tx, ty)
					
					vertex_alpha = topalpha
					vertex_add_real(vx, vy + blockh, hei, 0, 1, 0, tx, ty + ph)
					vertex_add_real(vx + blockw, vy + blockh, hei, 0, 1, 0, tx + pw, ty + ph)
					vertex_add_real(vx + blockw, vy + blockh, hei, 0, 1, 0, tx + pw, ty + ph)
					
					vertex_alpha = 1
					vertex_add_real(vx + blockw, vy + blockh, 0, 0, 1, 0, tx + pw, ty)
					vertex_add_real(vx, vy + blockh, 0, 0, 1, 0, tx, ty)
				}
				
				if (!hascolor[xx, mod_fix(yy - 1, texhei)])
				{
					vertex_rgb = colsideslight
					vertex_alpha = 1
					vertex_add_real(vx + blockw, vy, 0, 0, -1, 0, tx, ty)
					
					vertex_alpha = topalpha
					vertex_add_real(vx + blockw, vy, hei, 0, -1, 0, tx, ty + ph)
					vertex_add_real(vx, vy, hei, 0, -1, 0, tx + pw, ty + ph)
					vertex_add_real(vx, vy, hei, 0, -1, 0, tx + pw, ty + ph)
					
					vertex_alpha = 1
					vertex_add_real(vx, vy, 0, 0, -1, 0, tx + pw, ty)
					vertex_add_real(vx + blockw, vy, 0, 0, -1, 0, tx, ty)
				}
			}
		}
	}
	
	col = (env_sky_clouds_mode = "flat" ? coltop : colbottom)
	
	vertex_rgb = col
	vertex_alpha = 1
	
	vertex_add_real(0, 0, 0, 0, 0, -1, 0, 0)
	vertex_add_real(0, cloudsize, 0, 0, 0, -1, 0, 1)
	vertex_add_real(cloudsize, cloudsize, 0, 0, 0, -1, 1, 1)
	vertex_add_real(cloudsize, cloudsize, 0, 0, 0, -1, 1, 1)
	vertex_add_real(cloudsize, 0, 0, 0, 0, -1, 1, 0)
	vertex_add_real(0, 0, 0, 0, 0, -1, 0, 0)
	
	if (topalpha > 0)
	{
		vertex_rgb = coltop
		vertex_alpha = topalpha
		
		vertex_add_real(0, 0, hei, 0, 0, 1, 0, 0)
		vertex_add_real(cloudsize, 0, hei, 0, 0, 1, 1, 0)
		vertex_add_real(cloudsize, cloudsize, hei, 0, 0, 1, 1, 1)
		vertex_add_real(cloudsize, cloudsize, hei, 0, 0, 1, 1, 1)
		vertex_add_real(0, cloudsize, hei, 0, 0, 1, 0, 1)
		vertex_add_real(0, 0, hei, 0, 0, 1, 0, 0)
	
		vertex_rgb = c_white
		vertex_alpha = 1
	}
	
	vbuffer_done()
}
