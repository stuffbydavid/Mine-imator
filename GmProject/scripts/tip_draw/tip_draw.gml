/// tip_draw()

function tip_draw()
{
	if (tip_window != window_get_current())
		return 0;
	
	if (tip_show)
		tip_alpha = test_reduced_motion(1, min(1, tip_alpha + 0.1 * delta))
	else
		tip_alpha = test_reduced_motion(0, max(0, tip_alpha - 0.1 * delta))
	
	if (tip_alpha = 0)
	{
		tip_box_x = null
		tip_box_y = null
		tip_final_x = -1
		tip_final_y = -1
		tip_arrow_final_x = -1
		tip_arrow_final_y = -1
		return 0
	}
	
	if (tip_final_x = -1)
	{
		tip_final_x = tip_x
		tip_final_y = tip_y
		
		tip_arrow_final_x = tip_arrow_x
		tip_arrow_final_y = tip_arrow_y
	}
	else
	{
		tip_final_x += (tip_x - tip_final_x) / max(1, 4 / delta)
		tip_final_y += (tip_y - tip_final_y) / max(1, 4 / delta)
		
		tip_arrow_final_x += (tip_arrow_x - tip_arrow_final_x) / max(1, 4 / delta)
		tip_arrow_final_y += (tip_arrow_y - tip_arrow_final_y) / max(1, 4 / delta)
	}
	
	content_x = tip_final_x
	content_y = tip_final_y
	content_width = tip_w
	content_height = tip_h
	
	// Box
	draw_set_alpha(tip_alpha)
	draw_box(tip_final_x, tip_final_y, tip_w, tip_h, false, c_level_top, 1)
	draw_outline(tip_final_x, tip_final_y, tip_w, tip_h, 1, c_border, a_border, true)
	
	// Arrow
	render_set_culling(false)
	draw_image(spr_tooltip_arrow, tip_arrow * 2, tip_arrow_final_x, tip_arrow_final_y, tip_arrow_xscale, tip_arrow_yscale, c_level_top, 1, tip_right * 90)
	draw_image(spr_tooltip_arrow, (tip_arrow * 2) + 1, tip_arrow_final_x, tip_arrow_final_y, tip_arrow_xscale, tip_arrow_yscale, c_border, a_border, tip_right * 90)
	render_set_culling(true)
	
	// Text
	var texty = tip_final_y + tip_h - 4;
	
	if (tip_keybind_draw)
		draw_label(tip_text_keybind, tip_final_x + tip_w - 8, texty - 1, fa_right, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
	
	for (var i = 0; i < array_length(tip_text_array); i++)
	{
		var text = tip_text_array[i];
		
		if (tip_keybind_draw)
			draw_label(text, tip_final_x + 8, texty - 1, fa_left, fa_bottom, c_text_main, a_text_main, font_caption)
		else
			draw_label(text, tip_final_x + round(tip_w / 2), texty - 1, fa_center, fa_bottom, c_text_main, a_text_main, font_caption)
		
		texty -= (8 + 7)
	}
	
	draw_set_alpha(1)
	
	tip_show = false
}
