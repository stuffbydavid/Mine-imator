function popup_upgrade_draw()
{
	var pagealpha, pageoff;
	pagealpha = ease("easeoutcirc", popup_current.page_ani)
	pageoff = pagealpha * 16
	
	popup_current.page_ani += 0.05 * delta
	popup_current.page_ani = clamp(popup_current.page_ani, 0, 1)
	
	if (popup_current.page_ani_type = "left")
		pageoff -= 16
	else
		pageoff = 16 - pageoff
	
	draw_dropshadow(floor(dx + dw/2 - (sprite_get_width(spr_upgrade_img)/2)) + pageoff, dy, sprite_get_width(spr_upgrade_img), sprite_get_height(spr_upgrade_img), c_black, 1)
	draw_sprite_ext(spr_upgrade_img, popup_current.page, floor(dx + dw/2 - (sprite_get_width(spr_upgrade_img)/2)) + pageoff, dy, 1, 1, 0, c_white, pagealpha * draw_get_alpha())
	dy += sprite_get_height(spr_upgrade_img)
	
	if (draw_button_icon("upgrade/left", content_x + 12, dy - sprite_get_height(spr_upgrade_img)/2 - 16, 20, 32, false, icons.CHEVRON_LEFT))
	{
		popup_current.page = mod_fix((popup_current.page - 1), 3)
		popup_current.page_ani = 0
		popup_current.page_ani_type = "left"
	}
	
	if (draw_button_icon("upgrade/right", content_x + content_width - (12 + 20), dy - sprite_get_height(spr_upgrade_img)/2 - 16, 20, 32, false, icons.CHEVRON_RIGHT))
	{
		popup_current.page = mod_fix((popup_current.page + 1), 3)
		popup_current.page_ani = 0
		popup_current.page_ani_type = "right"
	}
	
	dy += 14
	
	// Image caption
	draw_set_font(font_caption)
	content_text = string_limit_ext(text_get("upgrade/page_" + string(popup_current.page)), (dw - 40) + 8, no_limit)
	draw_label(content_text, floor(dx + dw/2) + pageoff, dy, fa_middle, fa_top, c_text_secondary, a_text_secondary * pagealpha, font_caption)
	dy += string_height(content_text) + 24
	
	// Info
	draw_set_font(font_value)
	content_text = string_limit_ext(text_get("upgrade/info"), (dw - 40) + 8, no_limit)
	draw_label(content_text, floor(dx + dw/2), dy, fa_middle, fa_top, c_text_main, a_text_main, font_value)
	dy += string_height(content_text) + 30
	
	// Upgrade link
	draw_set_font(font_label)
	draw_button_text(link_upgrade, floor(dx + dw/2 - string_width(link_upgrade)/2), dy, open_url, link_upgrade, link_upgrade, font_label)
	
	dy += 18
	
	// Upgrade key textbox
	var wid = 196;
	
	tab_control(48)
	draw_inputbox("upgrade", dx + dw/2 - wid/2, dy, wid, 48, "XXXXXXXX", popup_upgrade.tbx_key, null, false, false, font_upgrade, e_inputbox.BIG)
	draw_box_hover(dx + dw/2 - wid/2, dy, wid, 48, microani_arr[e_microani.PRESS])
	
	if (draw_button_icon("upgrade/key_paste", dx + dw/2 + wid/2 + 8, dy + 10, 24, 24, false, icons.PASTE, null, false, "tooltip/paste_key"))
		popup_upgrade.tbx_key.text = string(clipboard_get_text())
	
	tab_next()
	dy += 10
	
	if (popup_upgrade.warntext != "")
	{
		tab_control(16)
		draw_label(text_get(popup_upgrade.warntext), dx + dw/2, dy + 8, fa_center, fa_bottom, c_error, 1, font_caption)
		tab_next()
	}
	
	tab_control_button_label()
	if (draw_button_label("upgrade/continue", dx + dw/2 + (key_expired ? 8 : 0), dy, null, icons.KEY, e_button.PRIMARY, null, key_expired ? e_anchor.LEFT : e_anchor.RIGHT))
	{
		var key = popup_upgrade.tbx_key.text;
		
		if (key_valid(key))
		{
			if (key = key_current && key_expired)
				popup_upgrade.warntext = "error/key_expired"
			
			else if (key = key_current && key_current_date_invalid)
				popup_upgrade.warntext = "error/upgrade"
			else
			{
				popup_upgrade.warntext = ""
				
				trial_upgrade(key)
				
				if (popup_switch_from)
					popup_switch(popup_switch_from)
				else
				{
					// Open "Advanced mode" popup
					if (popup_current.open_advanced)
					{
						popup_switch(popup_advanced)
						popup_upgrade.open_advanced = false
					}
					else
						popup_close()
				}
			}
		}
		else
			popup_upgrade.warntext = "error/upgrade"
	}
	
	if (key_expired && draw_button_label("upgrade/dismiss", dx + dw/2 - 8, dy, null, null, e_button.SECONDARY, null, e_anchor.RIGHT))
	{
		key_expired_dismissed = true
		key_save()
		popup_close()
	}
	tab_next()
}
