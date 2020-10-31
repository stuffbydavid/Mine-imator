/// popup_downloadskin_draw()

// Username input
tab_control(48)
draw_textfield("downloadskinusername", dx, dy, dw - 32, 28, popup.tbx_username, null, "", "top")

// Download button
var download = keyboard_check_pressed(vk_enter);

if (draw_button_icon("downloadskindownload", dx + dw - 24, dy + 20, 28, 28, false, icons.DOWNLOAD_SKIN, null, popup.tbx_username.text = "" || http_downloadskin != null, "tooltipdownloadskin"))
	download = true

if (download && (popup.tbx_username.text != "" && http_downloadskin = null))
{
	popup.username = popup.tbx_username.text
	popup.fail_message = ""
	popup.start_time = current_time
	http_downloadskin = http_get_file(link_skins + popup.username, download_image_file)
}

tab_next()

// Status
tab_control(8)
if (http_downloadskin != null)
{
	draw_label(text_get("downloadskindownloading"), dx, dy + 8, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_caption)
	
	if (current_time - popup.start_time > 3000) // Timeout
	{
		popup.fail_message = text_get("errordownloadskininternet")
		http_downloadskin = null
	}
}
else if (popup.fail_message != "")
	draw_label(popup.fail_message, dx, dy + 8, fa_left, fa_bottom, c_error, 1, font_caption)

tab_next()

// Skin preview
dx = content_x + content_width / 2 - 64
draw_box(dx, dy, 128, 128, false, c_background_secondary, 1)
if (popup.texture)
	draw_texture(popup.texture, dx, dy, 2, 2)

// Done
dx = content_x + 16
if (draw_button_primary("downloadskindone", dx, dy_start + dh - 28, null, null, null, fa_right, !popup.texture))
{
	popup_close()
	script_execute(popup.value_script, e_option.DOWNLOAD_SKIN_DONE)
}
