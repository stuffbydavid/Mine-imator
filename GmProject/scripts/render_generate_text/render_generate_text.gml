/// render_generate_text(string, resource, 3d, [halign, valign, aa, size])
/// @arg string
/// @arg resource
/// @arg 3d
/// @arg [halign]
/// @arg [valign]
/// @arg [aa]
/// @arg [size]
/// @desc Generates a vbuffer and a surface (text_vbuffer, text_texture)

function render_generate_text()
{
	var str, res, is3d, valign, halign, aa, size;
	var alignmatch, aamatch, sizematch;
	str = argument[0]
	res = res_eval(argument[1])
	is3d = argument[2]
	halign = "center"
	valign = "center"
	aa = true
	size = 3
	
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
	if (argument_count > 6)
		size = argument[6]
	if (res.type != e_res_type.FONT)
		size = 1
	size = clamp(size, 0, 8)
	sizematch = (text_outline_size_prev = size)
	text_outline_size_prev = size
	
	if (string_char_at(str, string_length(str)) = "\n")
		str += " "
	
	if (text_texture[0] != null && text_string = str && text_res = res && text_3d_prev = is3d && alignmatch && aamatch && sizematch)
		return 0
	
	text_string = str
	text_res = res
	text_3d_prev = is3d
	
	draw_set_font(aa ? res.font : res.font_no_aa)
	
	// Calculate dimensions
	var wid, hei, xx, zz, padding;
	padding = max(0, ceil(size) - 1)
	wid = string_width(str) + 1 + padding * 2
	hei = string_height_ext(str, string_height(" ") - 2, -1) + 4 + padding * 2
	
	switch (valign)
	{
		case "top": zz = -hei + 3 + padding; break;
		case "center": zz = -hei / 2 + 0.5; break;
		case "bottom": zz = -padding; break;
	}
	
	switch (halign)
	{
		case "left": xx = -1 - padding; break;
		case "center": xx = -wid / 2 - 1; break;
		case "right": xx = -wid + padding; break;
	}
	
	// Generate padded text surface
	var surf = surface_create(wid, hei);
	surface_set_target(surf)
	{
		draw_clear_alpha(c_black, 0)
		var color = draw_get_color();
		draw_set_color(c_white)
		
		var textxx;
		
		switch (halign)
		{
			case "left": textxx = 1 + padding; draw_set_halign(fa_left); break;
			case "center": textxx = ceil(wid / 2); draw_set_halign(fa_center); break;
			case "right": textxx = wid - padding; draw_set_halign(fa_right); break;
		}
		
		draw_text_ext(textxx, 2 + padding, str, string_height(" ") - 2, -1)
		
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
			shader_outline_set(wid, hei, size)
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
