/// popup_upgrade_draw()

function popup_upgrade_draw()
{
	var pageoff, pagealpha = 0;
	pagealpha = ease("easeoutcirc", popup.page_ani)
	pageoff = pagealpha * 16
	popup.page_ani += 0.05 * delta
	popup.page_ani = clamp(popup.page_ani, 0, 1)
		
	if (popup.page_ani_type = "left")
		pageoff -= 16
	else
		pageoff = 16 - pageoff
	
	draw_dropshadow(floor(dx + dw/2 - (sprite_get_width(spr_upgrade_img)/2)) + pageoff, dy, sprite_get_width(spr_upgrade_img), sprite_get_height(spr_upgrade_img), c_black, 1)
	draw_sprite_ext(spr_upgrade_img, popup.page, floor(dx + dw/2 - (sprite_get_width(spr_upgrade_img)/2)) + pageoff, dy, 1, 1, 0, c_white, pagealpha * draw_get_alpha())
	dy += sprite_get_height(spr_upgrade_img)
	
	if (draw_button_icon("upgradeleft", content_x + 12, dy - sprite_get_height(spr_upgrade_img)/2 - 16, 20, 32, false, icons.CHEVRON_LEFT))
	{
		popup.page = mod_fix((popup.page - 1), 3)
		popup.page_ani = 0
		popup.page_ani_type = "left"
	}
	
	if (draw_button_icon("upgraderight", content_x + content_width - (12 + 20), dy - sprite_get_height(spr_upgrade_img)/2 - 16, 20, 32, false, icons.CHEVRON_RIGHT))
	{
		popup.page = mod_fix((popup.page + 1), 3)
		popup.page_ani = 0
		popup.page_ani_type = "right"
	}
	
	dy += 14
	
	// Image caption
	draw_set_font(font_caption)
	var text = string_limit_ext(text_get("upgradepage" + string(popup.page)), (dw - 40) + 8, no_limit);
	draw_label(text, floor(dx + dw/2) + pageoff, dy, fa_middle, fa_top, c_text_secondary, a_text_secondary * pagealpha, font_caption)
	dy += string_height(text) + 24
	
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
			{
				// Open "Advanced mode" popup
				if (popup.open_advanced)
				{
					popup_switch(popup_advanced)
					popup_upgrade.open_advanced = false
				}
				else
					popup_close()
			}
		}
		else
			popup_upgrade.warntext = "errorupgrade"
	}
	tab_next()
}
