/// window_draw_load_assets()

// Background
draw_clear(setting_color_interface)

content_x = 25
content_y = 25
content_width = window_width - 50
content_height = window_height - 50
content_mouseon = true

// Cover image
if (new_assets_image_texture != null)
{
	draw_texture(new_assets_image_texture, content_x + floor(content_width / 2 - texture_width(new_assets_image_texture) / 2), content_y)
	content_y += texture_height(new_assets_image_texture) + 25
	content_height -= texture_height(new_assets_image_texture) + 25
}

// Title
draw_label(text_get("newassetstitle", new_assets_version), content_x + content_width / 2, content_y, fa_center, fa_top, null, 1, setting_font_big)

if (new_assets_stage = "download")
{
	// Loading
	draw_loading_bar(content_x, content_y + 100, content_width, 40, new_assets_download_progress, text_get("newassetsdownloading"))
}
else
{
	// Text
	draw_label(text_get("newassetstext"), content_x + content_width / 2, content_y + 32, fa_center, fa_top)

	// Download
	if (draw_button_normal("newassetsdownload", content_x + content_width / 2 - 125, content_y + content_height - 40, 120, 40))
	{
		if (new_assets_format > minecraft_assets_format)
		{
			if (question(text_get("questionassetsnewer")))
			{
				open_url(link_download)
				game_end()
				return 0
			}
		}
		else
		{
			new_assets_stage = "download"
			http_download_assets_file = http_get_file(link_assets + new_assets_version + ".midata", mc_file_directory + new_assets_version + ".midata")
		}
	}

	// Skip
	if (draw_button_normal("newassetslater", content_x + content_width / 2 + 5, content_y + content_height - 40, 120, 40))
	{
		tip_show = false
		if (!minecraft_assets_load_startup())
		{
			error("errorloadassets")
			game_end()
			return false
		}
	}

	// Changes
	content_y += 65
	content_height -= 130

	draw_box(content_x, content_y, content_width, content_height, false, setting_color_background, 1)

	var dy, itemhei;
	dy = 0
	itemhei = 24
	for (var i = round(new_assets_scroll.value / itemhei); i < array_length_1d(new_assets_changes_lines); i++)
	{
		if (dy + itemhei > content_height)
			break
		
		var text = new_assets_changes_lines[i];
		if (string_copy(text, 1, 2) = "* ")
		{
			draw_image(spr_circle_6, 0, content_x + 30, content_y + dy + itemhei / 2, 1, 1, setting_color_text, 1)
			draw_label(string_delete(text, 1, 2), content_x + 40, content_y + dy + itemhei / 2, fa_left, fa_middle)
		}
		else
			draw_label(text, content_x + 10, content_y + dy + itemhei / 2 + 2, fa_left, fa_middle)
		dy += itemhei
	}

	new_assets_scroll.snap_value = itemhei
	scrollbar_draw(new_assets_scroll, e_scroll.VERTICAL, content_x + content_width - 30, content_y, floor(content_height / itemhei) * itemhei, array_length_1d(new_assets_changes_lines) * itemhei)
}