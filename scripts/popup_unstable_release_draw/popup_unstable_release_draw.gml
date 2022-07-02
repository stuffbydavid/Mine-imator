/// popup_unstable_release_draw()

function popup_unstable_release_draw()
{
	dx = content_x + 12
	dw = content_width - 24
	
	draw_sprite(spr_bugs, 0, content_x, content_y)
	dy += 200 + 16
	
	dy += 12
	draw_label(text_get("unstabletitle", mineimator_version_extra), dx + dw / 2, dy, fa_center, fa_bottom, c_accent, 1, font_heading)
	dy += 10
	
	draw_label(text_get("unstableinfo"), dx, dy, fa_left, fa_top, c_text_main, a_text_main, font_value, -1, dw)
	
	draw_set_font(font_value)
	dy += string_height_ext(text_get("unstableinfo"), -1, dw) + 16
	
	tab_control_button_label()
	
	if (draw_checkbox("unstableinforead", dx, content_y + content_height - 40, popup_unstable.info_read, null))
		popup_unstable.info_read = !popup_unstable.info_read
	
	if (draw_button_label("unstablecontinue", dx + dw, content_y + content_height - 44, null, null, e_button.PRIMARY, null, e_anchor.RIGHT, !popup_unstable.info_read))
		popup_switch(popup_welcome)
	
	tab_next()
}
