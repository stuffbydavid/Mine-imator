/// tip_draw()

if (tip_show)
	tip_alpha = min(1, tip_alpha + 0.1 * delta)
else
	tip_alpha = max(0, tip_alpha - 0.1 * delta)

if (tip_alpha = 0)
{
	tip_box_x = null
	tip_box_y = null
	return 0
}

content_x = tip_x
content_y = tip_y
content_width = tip_w
content_height = tip_h

// Box
draw_set_alpha(tip_alpha)
draw_box(tip_x, tip_y, tip_w, tip_h, false, c_level_top, 1)
draw_outline(tip_x, tip_y, tip_w, tip_h, 1, c_border, a_border, true)

// Arrow
render_set_culling(false)
draw_image(spr_tooltip_arrow, tip_arrow * 2, tip_arrow_x, tip_arrow_y, tip_arrow_xscale, tip_arrow_yscale, c_level_top, 1, tip_right * 90)
draw_image(spr_tooltip_arrow, (tip_arrow * 2) + 1, tip_arrow_x, tip_arrow_y, tip_arrow_xscale, tip_arrow_yscale, c_border, a_border, tip_right * 90)
render_set_culling(true)

// Text
var texty = tip_y + tip_h - 4;

if (tip_keybind_draw)
	draw_label(tip_text_keybind, tip_x + tip_w - 8, texty - 1, fa_right, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)

for (var i = 0; i < array_length_1d(tip_text_array); i++)
{
	var text = tip_text_array[i];
	
	if (tip_keybind_draw)
		draw_label(text, tip_x + 8, texty - 1, fa_left, fa_bottom, c_text_main, a_text_main, font_caption)
	else
		draw_label(text, tip_x + round(tip_w / 2), texty - 1, fa_center, fa_bottom, c_text_main, a_text_main, font_caption)
	
	texty -= (8 + 7)
}

draw_set_alpha(1)

tip_show = false
