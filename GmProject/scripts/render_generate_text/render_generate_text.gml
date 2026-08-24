/// render_generate_text(string, resource, 3d, [halign, valign, [aa]])
/// @arg string
/// @arg resource
/// @arg 3d
/// @arg [halign
/// @arg valign
/// @arg [aa]]
/// @desc Generates a vbuffer and a surface (text_vbuffer, text_texture)

function render_generate_text_buffer(is3d, surf, xx, zz, wid, hei)
{
	vbuffer_start()
	
	// 3D pixels
	if (is3d)
		vbuffer_add_pixels(surface_get_alpha_array(surf), point3D(xx, 0, zz))
	
	var ysize, p1, p2, p3, p4, tsize, t1, t2, t3, t4,;
	t1 = vec2(0, 0)
	t2 = vec2(wid, 0)
	t3 = vec2(wid, hei)
	t4 = vec2(0, hei)
	
	// Convert coordinates to 0-1
	ysize = (is3d ? 1 : 0)
	tsize = vec2(wid, hei)
	t1 = vec2_div(t1, tsize)
	t2 = vec2_div(t2, tsize)
	t3 = vec2_div(t3, tsize)
	t4 = vec2_div(t4, tsize)
	
	// Front
	p1 = point3D(xx, ysize, zz + hei)
	p2 = point3D(xx + wid, ysize, zz + hei)
	p3 = point3D(xx + wid, ysize, zz)
	p4 = point3D(xx, ysize, zz)
	vbuffer_add_triangle(p1, p2, p3, t1, t2, t3)
	vbuffer_add_triangle(p3, p4, p1, t3, t4, t1)
	
	// Back
	p1 = point3D(xx, 0, zz + hei)
	p2 = point3D(xx + wid, 0, zz + hei)
	p3 = point3D(xx + wid, 0, zz)
	p4 = point3D(xx, 0, zz)
	vbuffer_add_triangle(p2, p1, p3, t2, t1, t3)
	vbuffer_add_triangle(p4, p3, p1, t4, t3, t1)
	
	return vbuffer_done()
}

function render_generate_text()
{
	var str, res, is3d, valign, halign, aa;
	var alignmatch, aamatch;
	str = argument[0]
	res = argument[1]
	is3d = argument[2]
	halign = "center"
	valign = "center"
	aa = true
	
	alignmatch = true
	aamatch = true
	
	// Alignment
	if (argument_count > 3)
	{
		halign = argument[3]
		valign = argument[4]
		
		alignmatch = (text_halign_prev = halign && text_valign_prev = valign)
		
		if (!alignmatch)
		{
			text_halign_prev = halign
			text_valign_prev = valign
		}
	}
	
	// Round up alpha
	if (argument_count > 5)
	{
		aa = argument[5]
		aamatch = (text_aa_prev = aa)
		
		if (!aamatch)
			text_aa_prev = aa
	}
	
	if (string_char_at(str, string_length(str)) = "\n")
		str += " "
	
	if (text_texture[0] != null && text_string = str && text_res = res && text_3d = is3d && alignmatch && aamatch)
		return 0
	
	text_string = str
	text_res = res
	text_3d = is3d
	
	draw_set_font(aa ? res.font : res.font_no_aa)
	
	// Calculate dimensions
	var wid, hei, xx, zz;
	wid = string_width(str) + 1
	hei = string_height_ext(str, string_height(" ") - 2, -1) + 4
	
	switch (valign)
	{
		case "top": zz = -hei + 3; break;
		case "center": zz = -hei / 2 + 0.5; break;
		case "bottom": zz = 0; break;
	}
	
	switch (halign)
	{
		case "left": xx = -1; break;
		case "center": xx = -wid / 2 - 1; break;
		case "right": xx = -wid; break;
	}
	
	// Generate surface with text on it (padded by 1px to avoid artifacts)
	var surf = surface_create(wid, hei);
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		var color = draw_get_color();
		draw_set_color(c_white)
		
		var textxx;
		
		switch (halign)
		{
			case "left": textxx = 1; draw_set_halign(fa_left); break;
			case "center": textxx = ceil(wid / 2); draw_set_halign(fa_center); break;
			case "right": textxx = wid; draw_set_halign(fa_right); break;
		}
		
		draw_text_ext(textxx, 2, str, string_height(" ") - 2, -1)
		
		draw_set_halign(fa_left)
		draw_set_color(color)
	}
	surface_reset_target()
	
	// Generate outline/glow
	var outlinesurf = surface_create(wid, hei);
	surface_set_target(outlinesurf)
	{
		draw_clear_alpha(c_black, 0)
		
		gpu_set_texrepeat(false)
		render_shader_obj = shader_map[?shader_outline]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_outline_set(wid, hei)
		}
		draw_surface_exists(surf, 0, 0)
		with (render_shader_obj)
			shader_reset()
			
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	draw_set_font(app.font_value)
	
	// Create textures
	if (text_texture[0] != null)
		texture_free(text_texture[0])
	text_texture[0] = texture_surface(surf)
	
	if (text_texture[1] != null)
		texture_free(text_texture[1])
	text_texture[1] = texture_surface(outlinesurf)
	
	// Create vbuffers
	text_vbuffer[0] = render_generate_text_buffer(is3d, surf, xx, zz, wid, hei)
	text_vbuffer[1] = render_generate_text_buffer(is3d, outlinesurf, xx, zz, wid, hei)
	
	surface_free(surf)
	surface_free(outlinesurf)
	
	return true
}
