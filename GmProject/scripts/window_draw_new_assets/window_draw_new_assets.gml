/// window_draw_new_assets()

function window_draw_new_assets()
{
	// Background
	draw_clear(c_level_top)
	
	content_width = 540
	content_height = 480
	content_x = floor((window_width/2) - content_width/2)
	content_y = floor((window_height/2) - content_height/2)
	content_mouseon = true
	
	dx = content_x
	dy = content_y
	dw = content_width
	dh = content_height
	
	draw_outline(dx, dy, dw, dh, 1, c_border, a_border, true)
	draw_dropshadow(dx, dy, dw, dh, c_black, 1)
	
	// Cover image
	if (new_assets_image_texture != null)
	{
		clip_begin(dx, dy, dw, 200)
		
		var scale = (dw / sprite_get_width(new_assets_image_texture));
		
		gpu_set_tex_filter(true)
		draw_sprite_ext(new_assets_image_texture, 0, dx, dy, scale, scale, 0, c_white, 1)
		gpu_set_tex_filter(false)
		
		clip_end()
	}
	
	// Title
	draw_label(text_get("newassetstitle", new_assets_version), dx + dw / 2, dy + 227, fa_center, fa_bottom, c_accent, 1, font_heading)
	draw_label(text_get("newassetssubtitle"), dx + dw / 2, dy + 244, fa_center, fa_bottom, c_text_main, a_text_main, font_value)
	
	dy += 264
	dx += 12
	dw -= 24
	
	if (new_assets_stage = "download")
	{
		// Loading
		tab_control_loading()
		draw_loading_bar(dx, dy, dw, 8, new_assets_download_progress, text_get("newassetsdownloading"))
		tab_next()
	}
	else
	{
		draw_set_font(font_button)
		var capwid = string_width(text_get("newassetsdownload")) + button_padding;
		
		// Download
		if (draw_button_label("newassetsdownload", dx + dw, (content_y + content_height) - 44, null, null, e_button.PRIMARY, null, fa_right))
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
		if (draw_button_label("newassetslater", (dx + dw) - (capwid + 8), (content_y + content_height) - 44, null, null, e_button.SECONDARY, null, fa_right))
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
		var scrolly = dy;
		
		dh = ((content_y + content_height) - 60) - dy
		dy_start = dy
		
		draw_outline(dx, dy, dw, dh, 1, c_border, a_border, true)
		clip_begin(dx + 1, dy + 1, dw - 2, dh - 2)
		
		dx += 8
		dw -= 16
		
		dy -= new_assets_scroll.value
		dy_start = dy
		
		dy += 16
		draw_label(text_get("newassetschangelog"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
		dy += 20
		
		for (var i = 0; i < array_length(new_assets_changes_lines); i++)
		{
			var text = new_assets_changes_lines[i];
			
			// Header
			if (string_copy(text, 1, 2) = "- ")
			{
				text = string_delete(text, 1, 2)
				draw_label(text, dx, dy, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
				dy += 20
			}
			else
			{
				if (string_copy(text, 1, 2) = "* ")
					text = "• " + string_delete(text, 1, 2)
				
				draw_label(text, dx, dy, fa_left, fa_bottom, c_text_main, a_text_main, font_value)
				dy += 17
			}
		}
		
		clip_end()
		
		window_scroll_focus = string(new_assets_scroll)
		scrollbar_draw(new_assets_scroll, e_scroll.VERTICAL, dx + dw - 8, scrolly + 8, dh - 16, (dy - dy_start - 21))
	}
}
