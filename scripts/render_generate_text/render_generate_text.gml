/// render_generate_text(string, resource)
/// @arg string
/// @arg resource
/// @desc Generates a vbuffer and a surface (text_vbuffer, text_texture)

var str, res, wid, hei, xx, zz, surf, color;
str = argument0
res = argument1

if (text_texture != null && text_string = str && text_res = res)
	return 0

text_string = str
text_res = res

draw_set_font(res.font)

// Calculate dimensions
wid = string_width(str) + 1
hei = string_height(str) + 1//string_height_ext(str, string_height(" ") + 1, -1) + 1
xx = -wid / 2
zz = hei / 2

// Generate surface with text on it
surf = surface_create(wid, hei)
surface_set_target(surf)
{
	draw_clear_alpha(c_black, 0)
	color = draw_get_color()
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(ceil(wid / 2), ceil(hei / 2), str)
	//draw_text_ext(ceil(wid / 2), ceil(hei / 2), str, string_height(" ") + 1, -1)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(color)
}
surface_reset_target()
texture_global_scale(1)
draw_set_font(app.setting_font)

// Create texture
if (text_texture != null)
	texture_free(text_texture)
text_texture = texture_surface(surf)
surface_free(surf)

// Create vbuffer
text_vbuffer = vbuffer_start()
vertex_add(xx, 0, zz, 0, 1, 0, 0, 0)
vertex_add(xx + wid, 0, zz, 0, 1, 0, 1, 0)
vertex_add(xx + wid, 0, zz - hei, 0, 1, 0, 1, 1)
vertex_add(xx, 0, zz, 0, 1, 0, 0, 0)
vertex_add(xx + wid, 0, zz - hei, 0, 1, 0, 1, 1)
vertex_add(xx, 0, zz - hei, 0, 1, 0, 0, 1)
vbuffer_done()