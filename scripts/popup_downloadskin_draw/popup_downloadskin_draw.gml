/// popup_downloadskin_draw()

// Username input
draw_inputbox("downloadskinusername", dx + 30, dy, 220, "", popup.tbx_username, null)
if (popup.tbx_username.text != "" && !popup.http)
{
	var wid = text_max_width("downloadskingetskin") + 20;
	if (draw_button_normal("downloadskingetskin", dx + 258, dy - 1, wid, 24))
	{
		popup.username = popup.tbx_username.text
		popup.http = http_get_file(link_skins + popup.username + ".png", download_file)
		popup.fail_message = ""
		popup.start_time = current_time
	}
}

// Skin preview
dx = content_x + content_width / 2 - 32
dy += 50
draw_box(dx, dy, 64, 64, false, setting_color_background, 1)
if (popup.texture)
	draw_texture(popup.texture, dx, dy)

// Status
dx = content_x + content_width / 2
dy += 68
if (popup.http != null)
{
	draw_label(text_get("downloadskindownloading"), dx, dy, fa_center, fa_top)
	if (current_time - popup.start_time > 3000) // Timeout
	{
		popup.fail_message = text_get("errordownloadskininternet")
		popup.http = null
	}
}
else if (popup.fail_message != "")
	draw_label(popup.fail_message, dx, dy, fa_center, fa_top, c_red, 1)
	
// Done
dx = content_x + content_width / 2 - 100 - 4
dy = content_y + content_height - 32
if (popup.texture)
{
	if (draw_button_normal("downloadskindone", dx, dy, 100, 32))
	{
		popup_close()
		script_execute(popup.value_script, e_option.DOWNLOAD_SKIN_DONE)
	}
	dx += 100 + 8
}
else
	dx = content_x + content_width / 2 - 50
	
// Cancel
if (draw_button_normal("downloadskincancel", dx, dy, 100, 32))
	popup_close()
