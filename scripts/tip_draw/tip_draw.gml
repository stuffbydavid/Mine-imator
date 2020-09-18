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
draw_box(tip_x, tip_y, tip_w, tip_h, false, c_background, 1)
draw_outline(tip_x, tip_y, tip_w, tip_h, 1, c_border, a_border)

// Arrow
render_set_culling(false)
draw_image(spr_tooltip_arrow, 0, tip_arrow_x, tip_arrow_y, 1, tip_arrow_yscale, c_background, 1, tip_right * 90)
draw_image(spr_tooltip_arrow, 1, tip_arrow_x, tip_arrow_y, 1, tip_arrow_yscale, c_border, a_border, tip_right * 90)
render_set_culling(true)

// Text
var texty;
texty = tip_y + tip_h - 4
for (var i = 0; i < array_length_1d(tip_text_array); i++)
{
	var text = tip_text_array[i];
	
	if (tip_shortcut_draw)
	{
		if (i = 0)
			draw_label(text, tip_x + 8, texty - 1, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_caption)
		else
			draw_label(text, tip_x + 8, texty - 1, fa_left, fa_bottom, c_text_main, a_text_main, font_caption)
	}
	else
		draw_label(text, tip_x + round(tip_w / 2), texty - 1, fa_center, fa_bottom, c_text_main, a_text_main, font_caption)
	
	texty -= (8 + 7)
}

draw_set_alpha(1)

tip_show = false
