/// background_sky_update_clouds()
/// @desc Updates the vbuffer to be used for fancy/poor clouds.

var tex, texwid, texhei, texsize, hei, topalpha, cloudsize, col, colsidesdark, colsideslight, coltop, colbottom;

if (!background_sky_clouds_tex.ready)
	return 0

tex = test((background_sky_clouds_tex.type = e_res_type.PACK), background_sky_clouds_tex.clouds_texture, background_sky_clouds_tex.texture)
texwid = texture_width(tex)
texhei = texture_height(tex)
texsize = max(texwid, texhei)
hei = 0

if (background_sky_clouds_story_mode)
{
	colsidesdark = make_color_rgb(216, 230, 255)
	colsideslight = make_color_rgb(216, 230, 255)
	coltop = make_color_rgb(216, 230, 255)
	colbottom = make_color_rgb(216, 230, 255)
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
if (background_sky_clouds_vbuffer)
	vbuffer_destroy(background_sky_clouds_vbuffer)

background_sky_clouds_vbuffer = vbuffer_start()
cloudsize = background_sky_clouds_size * 32

if (!background_sky_clouds_flat)
{
	var surf = surface_create(texwid, texhei);
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		draw_texture(tex, 0, 0)
	}
	surface_reset_target()
	
	buffer_current = buffer_create(texwid * texhei * 4, buffer_fixed, 4)
	buffer_get_surface(buffer_current, surf, 0, 0, 0)
	
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
	hei = background_sky_clouds_height
	
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
				vertex_add(vx + blockw, vy + blockh, 0, 1, 0, 0, tx, ty, colsidesdark, 1)
				vertex_add(vx + blockw, vy + blockh, hei, 1, 0, 0, tx, ty + ph, colsidesdark, topalpha)
				vertex_add(vx + blockw, vy, hei, 1, 0, 0, tx + pw, ty + ph, colsidesdark, topalpha)
				vertex_add(vx + blockw, vy, hei, 1, 0, 0, tx + pw, ty + ph, colsidesdark, topalpha)
				vertex_add(vx + blockw, vy, 0, 1, 0, 0, tx + pw, ty, colsidesdark, 1)
				vertex_add(vx + blockw, vy + blockh, 0, 1, 0, 0, tx, ty, colsidesdark, 1)
			}
			
			if (!hascolor[mod_fix(xx - 1, texwid), yy])
			{
				vertex_add(vx, vy, 0, -1, 0, 0, tx, ty, colsidesdark, 1)
				vertex_add(vx, vy, hei, -1, 0, 0, tx, ty + ph, colsidesdark, topalpha)
				vertex_add(vx, vy + blockh, hei, -1, 0, 0, tx + pw, ty + ph, colsidesdark, topalpha)
				vertex_add(vx, vy + blockh, hei, -1, 0, 0, tx + pw, ty + ph, colsidesdark, topalpha)
				vertex_add(vx, vy + blockh, 0, -1, 0, 0, tx + pw, ty, colsidesdark, 1)
				vertex_add(vx, vy, 0, -1, 0, 0, tx, ty, colsidesdark, 1)
			}
			
			if (!hascolor[xx, (yy + 1) mod texhei])
			{
				vertex_add(vx, vy + blockh, 0, 0, 1, 0, tx, ty, colsideslight, 1)
				vertex_add(vx, vy + blockh, hei, 0, 1, 0, tx, ty + ph, colsideslight, topalpha)
				vertex_add(vx + blockw, vy + blockh, hei, 0, 1, 0, tx + pw, ty + ph, colsideslight, topalpha)
				vertex_add(vx + blockw, vy + blockh, hei, 0, 1, 0, tx + pw, ty + ph, colsideslight, topalpha)
				vertex_add(vx + blockw, vy + blockh, 0, 0, 1, 0, tx + pw, ty, colsideslight, 1)
				vertex_add(vx, vy + blockh, 0, 0, 1, 0, tx, ty, colsideslight, 1)
			}
			
			if (!hascolor[xx, mod_fix(yy - 1, texhei)])
			{
				vertex_add(vx + blockw, vy, 0, 0, -1, 0, tx, ty, colsideslight, 1)
				vertex_add(vx + blockw, vy, hei, 0, -1, 0, tx, ty + ph, colsideslight, topalpha)
				vertex_add(vx, vy, hei, 0, -1, 0, tx + pw, ty + ph, colsideslight, topalpha)
				vertex_add(vx, vy, hei, 0, -1, 0, tx + pw, ty + ph, colsideslight, topalpha)
				vertex_add(vx, vy, 0, 0, -1, 0, tx + pw, ty, colsideslight, 1)
				vertex_add(vx + blockw, vy, 0, 0, -1, 0, tx, ty, colsideslight, 1)
			}
		}
	}
}

col = test(background_sky_clouds_flat, coltop, colbottom)

vertex_add(0, 0, 0, 0, 0, -1, 0, 0, col, 1)
vertex_add(0, cloudsize, 0, 0, 0, -1, 0, 1, col, 1)
vertex_add(cloudsize, cloudsize, 0, 0, 0, -1, 1, 1, col, 1)
vertex_add(cloudsize, cloudsize, 0, 0, 0, -1, 1, 1, col, 1)
vertex_add(cloudsize, 0, 0, 0, 0, -1, 1, 0, col, 1)
vertex_add(0, 0, 0, 0, 0, -1, 0, 0, col, 1)

vertex_add(0, 0, hei, 0, 0, 1, 0, 0, coltop, topalpha)
vertex_add(cloudsize, 0, hei, 0, 0, 1, 1, 0, coltop, topalpha)
vertex_add(cloudsize, cloudsize, hei, 0, 0, 1, 1, 1, coltop, topalpha)
vertex_add(cloudsize, cloudsize, hei, 0, 0, 1, 1, 1, coltop, topalpha)
vertex_add(0, cloudsize, hei, 0, 0, 1, 0, 1, coltop, topalpha)
vertex_add(0, 0, hei, 0, 0, 1, 0, 0, coltop, topalpha)

vbuffer_done()
