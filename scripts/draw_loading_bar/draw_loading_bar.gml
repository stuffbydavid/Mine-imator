/// draw_loading_bar(x, y, width, height, percent, text)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg percent
/// @arg text

var xx, yy, wid, hei, perc, text;
var surf, surfwid;
xx = argument0
yy = argument1
wid = argument2
hei = argument3
perc = argument4
text = argument5

surfwid = floor(wid * perc)
if (surfwid > 0)
{
	var col = draw_get_color();
	surf = surface_create(surfwid, hei)
	surface_set_target(surf)
	{
		draw_clear(setting_color_buttons)
		draw_set_color(setting_color_buttons_text)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_text(floor(wid / 2), floor(hei / 2), text)
		draw_set_valign(fa_top)
		draw_set_halign(fa_left)
		draw_set_color(col)
	}
	surface_reset_target()
}
else
	surf = null

draw_box(xx, yy, wid, hei, false, setting_color_background, 1)
draw_label(text, xx + floor(wid / 2), yy + floor(hei / 2), fa_center, fa_middle)
draw_surface_exists(surf, xx, yy)

surface_free(surf)
