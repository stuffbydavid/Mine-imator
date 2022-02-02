/// popup_upgrade_draw()

function popup_upgrade_draw()
{
	draw_sprite(spr_watermark_example, 0, floor(dx + dw/2 - (sprite_get_width(spr_watermark_example)/2)), dy)
	dy += sprite_get_height(spr_watermark_example)
	
	dy += 18
	
	// Info
	draw_set_font(font_value)
	var text = string_limit_ext(text_get("upgradeinfo"), (dw - 40) + 8, no_limit);
	draw_label(text, floor(dx + dw/2), dy, fa_middle, fa_top, c_text_main, a_text_main, font_value)
	
	dy += string_height(text) + 30
	
	// Upgrade link
	draw_set_font(font_value_bold)
	draw_button_text(link_upgrade, floor(dx + dw/2 - string_width(link_upgrade)/2), dy, open_url, link_upgrade, link_upgrade, font_value_bold)
	
	dy += 18
	
	// Upgrade key textbox
	var wid = 196;
	
	tab_control(48)
	draw_inputbox("upgrade", dx + dw/2 - wid/2, dy, wid, 48, "XXXXXXXX", popup_upgrade.tbx_key, null, false, false, font_upgrade, e_inputbox.BIG)
	draw_box_hover(dx + dw/2 - wid/2, dy, wid, 48, microani_arr[e_microani.PRESS])
	
	if (draw_button_icon("upgradekeypaste", dx + dw/2 + wid/2 + 8, dy + 10, 24, 24, false, icons.PASTE, null, false, "tooltippastekey"))
		popup_upgrade.tbx_key.text = string(clipboard_get_text())
	
	tab_next()
	dy += 10
	
	if (popup_upgrade.warntext != "")
	{
		tab_control(8)
		draw_label(text_get(popup_upgrade.warntext), dx + dw/2, dy + 8, fa_center, fa_bottom, c_error, 1, font_caption)
		tab_next()
	}
	
	tab_control_button_label()
	if (draw_button_label("upgradecontinue", dx + dw, dy, null, icons.KEY, e_button.PRIMARY, null, e_anchor.RIGHT))
	{
		var upgrade = trial_upgrade(popup_upgrade.tbx_key.text);
		
		if (upgrade)
		{
			if (popup_switch_from)
				popup_switch(popup_switch_from)
			else
				popup_close()
		}
		else
			popup_upgrade.warntext = "errorupgrade"
	}
	tab_next()
}
