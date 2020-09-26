/// popup_upgrade_draw()

draw_box(dx, dy, 328, 184, false, c_background_secondary, 1)
dy += 184

dy += 18

// Info
draw_label(string_limit_ext(text_get("upgradeinfo"), dw + 8, dh), dx, dy, fa_left, fa_top, c_text_main, a_text_main, font_value)

dy += 126

// Upgrade link
draw_set_font(font_value_bold)
draw_button_text("mineimator.com/upgrade", dx + dw/2 - string_width("mineimator.com/upgrade")/2, dy, open_url, "http://mineimator.com/upgrade", "http://mineimator.com/upgrade", font_value_bold)

dy += 18

// Upgrade key textbox
var wid = 196;
draw_inputbox("upgrade", dx + dw/2 - wid/2, dy, wid, 48, "XXXXXXXX", popup_upgrade.tbx_key, null, false, false, font_upgrade, true)

if (draw_button_icon("upgradekeypaste", dx + dw/2 + wid/2 + 8, dy + 10, 28, 28, false, icons.PASTE, null, false, "tooltippastekey"))
	popup_upgrade.tbx_key.text = string(clipboard_get_text())

dy += 56

if (popup_upgrade.warntext != "")
{
	tab_control(8)
	draw_label(text_get(popup_upgrade.warntext), dx + dw/2, dy + 8, fa_center, fa_bottom, c_error, 1, font_caption)
	tab_next()
}

if (draw_button_primary("upgradecontinue", dx, dy_start + dh - 36, null, null, icons.UPGRADE, fa_right))
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
