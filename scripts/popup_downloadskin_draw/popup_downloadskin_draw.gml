/// popup_downloadskin_draw()

// Username input
tab_control_textfield()
draw_textfield("downloadskinusername", dx, dy, dw - 28, 24, popup.tbx_username, null)

// Download button
var download = keyboard_check_pressed(vk_enter);

if (draw_button_icon("downloadskindownload", dx + dw - 24, dy + 18, 24, 24, false, icons.DOWNLOAD_SKIN, null, popup.tbx_username.text = "" || http_downloadskin != null, "tooltipdownloadskin"))
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
var previewx = content_x + content_width / 2 - 64;

tab_control(128)
draw_box(previewx, dy, 128, 128, false, c_level_bottom, 1)
if (popup.texture)
	draw_texture(popup.texture, previewx, dy, 2, 2)
tab_next()

// Done
tab_control_button_label()
if (draw_button_label("downloadskindone", dx + dw, dy_start + dh - 32, null, null, e_button.PRIMARY, null, e_anchor.RIGHT, !popup.texture))
{
	popup_close()
	script_execute(popup.value_script, e_option.DOWNLOAD_SKIN_DONE)
}
tab_next()
