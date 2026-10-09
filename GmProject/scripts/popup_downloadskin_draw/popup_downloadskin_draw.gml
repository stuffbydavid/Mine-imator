function popup_downloadskin_draw()
{
	// Username input
	tab_control_textfield()
	draw_textfield("download_skin/username", dx, dy, dw - 28, 24, popup_current.tbx_username, null)
	
	// Download button
	var download = keyboard_check_pressed(vk_enter);
	
	if (draw_button_icon("download_skin/download", dx + dw - 24, dy + 18, 24, 24, false, icons.DOWNLOAD, null, popup_current.tbx_username.text = "" || http_downloadskin != null, "tooltip/download_skin"))
		download = true
	
	if (download && (popup_current.tbx_username.text != "" && http_downloadskin = null))
	{
		popup_current.username = popup_current.tbx_username.text
		popup_current.fail_message = ""
		popup_current.start_time = current_time
		http_downloadskin = http_get_file(link_skins + popup_current.username, download_image_file)
	}
	
	tab_next()
	
	// Status
	tab_control(8)
	if (http_downloadskin != null)
	{
		draw_label(text_get("download_skin/downloading"), dx, dy + 8, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
	
		if (current_time - popup_current.start_time > 3000) // Timeout
		{
			popup_current.fail_message = text_get("error/download_skin_internet")
			http_downloadskin = null
		}
	}
	else if (popup_current.fail_message != "")
		draw_label(popup_current.fail_message, dx, dy + 8, fa_left, fa_bottom, c_error, 1, font_caption)
	
	tab_next()
	
	// Skin preview
	var previewx = content_x + content_width / 2 - 64;
	
	tab_control(128)
	draw_box(previewx, dy, 128, 128, false, c_level_bottom, 1)
	if (popup_current.texture)
		draw_texture(popup_current.texture, previewx, dy, 2, 2)
	tab_next()
	
	// Done
	tab_control_button_label()
	if (draw_button_label("download_skin/done", dx + dw, dy, null, null, e_button.PRIMARY, null, e_anchor.RIGHT, !popup_current.texture))
	{
		popup_close()
		script_execute(popup_current.value_script, e_option.DOWNLOAD_SKIN_DONE)
	}
	tab_next()
}
