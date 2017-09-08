/// popup_upgrade_draw()

// Info
draw_label(string_limit_ext(text_get("upgradeinfo1"), dw, dh), dx, dy)

dy += 170
draw_image(spr_watermark_example, 0, dx + dw / 2, dy)
dy += 130

draw_label(string_limit_ext(text_get("upgradeinfo2"), dw, dh), dx, dy)

// Upgrade
dy += 40
if (draw_button_normal("upgradebutton", dx + dw / 2 - 50, dy, 100, 40))
	open_url(link_upgrade)
	
// Enter key
dy += 70
draw_inputbox("upgradekey", dx + 70, dy, 290, "", popup_upgrade.tbx_key, null, 50, 40, 4, setting_font_big)
if (draw_button_normal("upgradekeypaste", dx + 370, dy + 8, 60, 28))
	popup_upgrade.tbx_key.text = string(clipboard_get_text())
	
// Continue
dw = 100
dh = 32
dx = content_x + content_width / 2 - dw - 4
dy = content_y + content_height - 32
if (draw_button_normal("upgradecontinue", dx, dy, dw, 32))
{
	if (trial_upgrade(popup_upgrade.tbx_key.text))
	{
		if (popup_switch_from)
			popup_switch(popup_switch_from)
		else
			popup_close()
	}
}

// Cancel
dx = content_x + content_width / 2 + 4
if (draw_button_normal("upgradecancel", dx, dy, dw, 32))
{
	if (popup_switch_from)
		popup_switch(popup_switch_from)
	else
		popup_close()
}
