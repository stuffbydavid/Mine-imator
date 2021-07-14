/// view_draw(view)
/// @arg view

function view_draw(view)
{
	var cam, camname;
	var captionx, captiony, captionw, captionh;
	var boxx, boxy, boxw, boxh;
	var padding, dx, dy;
	var location, split, mouseonresizesplit, mouseonresizehor, mouseonresizever;
	
	if (!view.show)
		return 0
	
	// Calculate box
	boxx = view_area_x
	boxy = view_area_y
	boxw = view_area_width
	boxh = view_area_height
	mouseonresizesplit = false
	mouseonresizehor = false
	mouseonresizever = false
	location = view.location
	split = view_split
	
	if (view = view_second)
		split = 1-split
	else if (!view_second.show)
		location = "full"
	
	if (view = view_main && view_second.show && view_main.quality = e_view_mode.RENDER && view_second.quality = e_view_mode.RENDER)
		view_main.quality = e_view_mode.SHADED
	
	switch (location)
	{	
		case "top":
			boxh -= view_area_height * split
			mouseonresizesplit = app_mouse_box(boxx, boxy + boxh - 4, boxw, 8)
			break
		
		case "right":
			boxx += view_area_width * split
			boxw -= view_area_width * split
			mouseonresizesplit = app_mouse_box(boxx, boxy, 8, boxh)
			break
		
		case "bottom":
			boxy += view_area_height * split
			boxh -= view_area_height * split
			mouseonresizesplit = app_mouse_box(boxx, boxy, boxw, 8)
			break
		
		case "left":
			boxw -= view_area_width * split
			mouseonresizesplit = app_mouse_box(boxx + boxw - 4, boxy, 8, boxh)
			break
		
		case "right_top":
			boxw = min(view_area_width, view.width)
			boxh = min(view_area_height, view.height)
			boxx += view_area_width - boxw
			mouseonresizehor = app_mouse_box(boxx, boxy, 8, boxh)
			mouseonresizever = app_mouse_box(boxx, boxy + boxh - 4, boxw, 8)
			break
		
		case "right_bottom":
			boxw = min(view_area_width, view.width)
			boxh = min(view_area_height, view.height)
			boxx += view_area_width - boxw
			boxy += view_area_height - boxh
			mouseonresizehor = app_mouse_box(boxx, boxy, 8, boxh)
			mouseonresizever = app_mouse_box(boxx, boxy, boxw, 8)
			break
		
		case "left_bottom":
			boxw = min(view_area_width, view.width)
			boxh = min(view_area_height, view.height)
			boxy += view_area_height - boxh
			mouseonresizehor = app_mouse_box(boxx + boxw - 4, boxy, 8, boxh)
			mouseonresizever = app_mouse_box(boxx, boxy, boxw, 8)
			break
		
		case "left_top":
			boxw = min(view_area_width, view.width)
			boxh = min(view_area_height, view.height)
			mouseonresizehor = app_mouse_box(boxx + boxw - 4, boxy, 8, boxh)
			mouseonresizever = app_mouse_box(boxx, boxy + boxh - 4, boxw, 8)
			break
	}
	
	if (popup_mouseon)
	{
		mouseonresizehor = false
		mouseonresizever = false
		mouseonresizesplit = false
	}
	
	boxx = floor(boxx)
	boxy = floor(boxy)
	boxw = ceil(boxw)
	boxh = ceil(boxh)
	
	if (boxw < 1 || boxh < 1)
		return 0
	
	content_x = boxx
	content_y = boxy
	content_width = boxw
	content_height = boxh
	content_mouseon = (view.mouseon && !popup_mouseon)
	
	if (window_busy = "viewmove" && view = view_second)
	{
		boxx = mouse_x - (boxw/2)
		boxy = mouse_y
	
		content_x = boxx
		content_y = boxy
		
		draw_set_alpha(1)
	}
	
	if (view = view_second)
		draw_dropshadow(boxx, boxy, boxw, boxh, c_black, 1)
	
	draw_box(boxx, boxy, boxw, boxh, false, c_level_middle, 1)
	
	// Set camera to use
	if (view = view_second)
		cam = timeline_camera
	else
		cam = null
	
	// Caption
	padding = 4
	captionx = boxx + 12
	captiony = boxy + padding
	captionw = boxw
	captionh = 32
	
	scissor_start(boxx, boxy, boxw, 32)
	
	// Buttons
	dw = 24
	dh = 24
	dx = boxx + boxw - (dw + padding)
	dy = boxy + padding
	
	microani_prefix = string(view)
	
	if (view = view_main && view_second.show && window_busy != "viewmove")
	{
		if (view_second.location = "left_top")
			captionx += view_second.width
		
		if (view_second.location = "right_top")
			dx -= view_second.width
		
		if (view_second.location = "left_top" || view_second.location = "right_top")
			captionw -= view_second.width
	}
	
	if (view = view_second)
	{
		// Close view
		if (draw_button_icon("viewclose", dx, dy, dw, dh, false, icons.CLOSE, null, false, "viewclose"))
		{
			view.show = false
			view_render = false
		}
	}
	else
	{
		// Close/hide second view
		tip_set_keybind(e_keybind.SECONDARY_VIEW)
		if (draw_button_icon("viewsecond", dx, dy, dw, dh, view_second.show, icons.VIEWPORT_SECONDARY, null, false, view_second.show ? "viewseconddisable" : "viewsecondenable"))
			view_second.show = !view_second.show
	}
	
	dx -= (padding + 1)
	draw_divide_vertical(dx, dy, dh)
	dx -= 16 + padding
	
	// Quality settings
	if (draw_button_icon("viewqualitysettings", dx, dy, 16, 24, settings_menu_name = (string(view) + "viewqualitysettings"), icons.CHEVRON_DOWN_TINY))
	{
		menu_settings_set(dx, dy, (string(view) + "viewqualitysettings"), 24)
		settings_menu_view = view
		settings_menu_script = menu_quality_settings
	}
	
	if (settings_menu_name = (string(view) + "viewqualitysettings") && settings_menu_ani_type != "hide")
		current_microani.value = true
	
	dx -= dw
	
	// "Render" quality
	tip_set_keybind(e_keybind.RENDER_MODE)
	if (draw_button_icon("viewmoderender", dx, dy, dw, dh, view.quality = e_view_mode.RENDER, setting_theme.dark ? icons.QUALITY_RENDERED__DARK : icons.QUALITY_RENDERED, null, false, "viewmoderender"))
	{
		view.quality = e_view_mode.RENDER
		
		if (view = view_main && view_second.quality = e_view_mode.RENDER)
			view_second.quality = e_view_mode.SHADED
		
		if (view = view_second && view_main.quality = e_view_mode.RENDER)
			view_main.quality = e_view_mode.SHADED
	}
	dx -= dw + padding
	
	// "Shaded" quality
	tip_set_keybind(e_keybind.RENDER_MODE)
	if (draw_button_icon("viewmodeshaded", dx, dy, dw, dh, view.quality = e_view_mode.SHADED, setting_theme.dark ? icons.SPHERE__DARK : icons.SPHERE, null, false, "viewmodeshaded"))
		view.quality = e_view_mode.SHADED
	dx -= dw + padding
	
	// "Flat" quality
	if (draw_button_icon("viewmodeflat", dx, dy, dw, dh, view.quality = e_view_mode.FLAT, icons.QUALITY_DRAFT, null, false, "viewmodeflat"))
		view.quality = e_view_mode.FLAT
	
	dx -= (padding + 1)
	draw_divide_vertical(dx, dy, dh)
	dx -= dw + padding
	
	// Effects
	if (cam != null)
	{
		if (draw_button_icon("vieweffects", dx, dy, dw, dh, view.effects, icons.WAND, null, false, view.effects ? "vieweffectsdisable" : "vieweffectsenable"))
			view.effects = !view.effects
		dx -= dw + padding
	}
	
	// Particles
	if (draw_button_icon("viewparticles", dx, dy, dw, dh, view.particles, icons.FIREWORKS, null, false, view.particles ? "viewparticlesdisable" : "viewparticlesenable"))
		view.particles = !view.particles
	dx -= 16 + padding
	
	// Overlay settings
	if (draw_button_icon("viewoverlaysettings", dx, dy, 16, 24, settings_menu_name = (string(view) + "viewoverlaysettings"), icons.CHEVRON_DOWN_TINY))
	{
		menu_settings_set(dx, dy, (string(view) + "viewoverlaysettings"), 24)
		settings_menu_view = view
		settings_menu_script = menu_overlay_settings
	}
	
	if (settings_menu_name = (string(view) + "viewoverlaysettings") && settings_menu_ani_type != "hide")
		current_microani.value = true
	dx -= dw
	
	// Overlays
	if (draw_button_icon("viewoverlays", dx, dy, dw, dh, view.overlays, icons.OVERLAYS, null, false, view.overlays ? "viewoverlaysdisable" : "viewoverlaysenable"))
		view.overlays = !view.overlays
	
	// Snap settings
	if (view = view_main)
	{
		dx -= (padding + 1)
		draw_divide_vertical(dx, dy, dh)
		dx -= 16 + padding
		
		if (draw_button_icon("viewsnapsettings", dx, dy, 16, 24, settings_menu_name = (string(view) + "viewsnapsettings"), icons.CHEVRON_DOWN_TINY))
		{
			menu_settings_set(dx, dy, (string(view) + "viewsnapsettings"), 24)
			settings_menu_view = view
			settings_menu_script = menu_snap_settings
		}
		
		if (settings_menu_name = (string(view) + "viewsnapsettings") && settings_menu_ani_type != "hide")
			current_microani.value = true
		dx -= dw
		
		tip_set_keybind(e_keybind.SNAP)
		if (draw_button_icon("viewsnap", dx, dy, dw, dh, setting_snap, icons.MAGNET, null, false, setting_snap ? "viewsnapdisable" : "viewsnapenable"))
			setting_snap = !setting_snap
	}
	
	// Camera name
	if (!cam)
		camname = text_get("viewworkcamera")
	else if (cam.selected)
		camname = text_get("viewselectedcamera", string_remove_newline(cam.display_name))
	else
		camname = text_get("viewactivecamera", string_remove_newline(cam.display_name))
	
	draw_label(string_limit(camname, dx - captionx), captionx, boxy + floor(captionh/2), fa_left, fa_middle, c_text_main, a_text_main, font_value)
	
	microani_prefix = ""
	scissor_done()
	
	// Screen
	content_x = boxx
	content_y = boxy + captionh
	content_width = boxw
	content_height = boxh - captionh
	content_mouseon = false
	
	if (location != "full" && location != "top" && location != "bottom")
	{
		if (!string_contains(location, "left"))
		{
			content_x += 3
			content_width -= 3
		}
		
		if (!string_contains(location, "right"))
			content_width -= 3
		
		if (location = "right_top" || location = "left_top")
			content_height -= 3
	}
	
	if (content_width > 0 && content_height > 0)
	{
		// Draw background
		draw_box(content_x, content_y, content_width, content_height, false, c_black, 1)
		
		// Match aspect ratio
		if (view.aspect_ratio && view.overlays)
		{
			var wid, hei, scale;
			
			if (cam && !cam.value[e_value.CAM_SIZE_USE_PROJECT])
			{
				wid = cam.value[e_value.CAM_WIDTH]
				hei = cam.value[e_value.CAM_HEIGHT]
			}
			else
			{
				wid = project_video_width
				hei = project_video_height
			}
			
			if (wid / hei < content_width / content_height)
			{
				scale = content_height / hei
				content_x += (content_width - scale * wid) / 2
				content_width = wid * scale
			}
			else
			{
				scale = content_width / wid
				content_y += (content_height - scale * hei) / 2
				content_height = hei * scale
			}
		}
		
		// Content
		content_x = floor(content_x)
		content_y = floor(content_y)
		content_width = ceil(content_width)
		content_height = ceil(content_height)
		content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && view.mouseon && !view.toolbar_mouseon && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
		
		if (content_mouseon)
			shortcut_bar_state = "viewport" + (cam = null ? "" : "cam")
		
		if (!view.quality = e_view_mode.RENDER || view_render_real_time)
			view_update(view, cam)
		else if (window_focus = string(view) && !mouse_left && !mouse_right) // Freeze on slow renders bugfix
			window_busy = ""
		
		draw_surface_size(view.surface, content_x, content_y, content_width, content_height)
		
		if (view.grid && view.overlays)
		{
			var cellwid, cellhei;
			cellwid = content_width / project_grid_rows
			cellhei = content_height / project_grid_columns
			
			for (var i = 1; i < project_grid_rows; i++)
			{
				draw_line_ext(content_x + cellwid * i - 1, content_y, content_x + cellwid * i - 1, content_y + content_height, c_white, 1)
				draw_line_ext(content_x + cellwid * i + 1, content_y, content_x + cellwid * i + 1, content_y + content_height, c_white, 1)
			}
			
			for (var i = 1; i < project_grid_columns; i++)
			{
				draw_line_ext(content_x, content_y + cellhei * i - 1, content_x + content_width, content_y + cellhei * i - 1, c_white, 1)
				draw_line_ext(content_x, content_y + cellhei * i + 1, content_x + content_width, content_y + cellhei * i + 1, c_white, 1)
			}
		}
	}
	
	// Revert content size for overlays
	content_x = boxx
	content_y = boxy + captionh
	content_width = boxw
	content_height = boxh - captionh
	
	// Toolbar
	if (view = view_main)
		view_toolbar_draw(view, boxx + 8, boxy + captionh + 8)
	
	// Moving / Resizing
	if (view = view_second) 
	{
		if (view.mouseon && (mouse_cursor = cr_default || content_mouseon))
		{
			if (mouseonresizehor && mouseonresizever) // Both
			{
				if (view.location = "right_top" || view.location = "left_bottom")
					mouse_cursor = cr_size_nesw
				else
					mouse_cursor = cr_size_nwse
				
				if (mouse_left_pressed)
				{
					window_busy = "viewresizeboth"
					view_resize_width = view.width
					view_resize_height = view.height
				}
			}
			else if (mouseonresizehor) // Horizontal
			{
				mouse_cursor = cr_size_we
				if (mouse_left_pressed)
				{
					window_busy = "viewresizehor"
					view_resize_width = view.width
				}
			}
			else if (mouseonresizever) // Vertical
			{
				mouse_cursor = cr_size_ns
				if (mouse_left_pressed)
				{
					window_busy = "viewresizever"
					view_resize_height = view.height
				}
			}
			else if (app_mouse_box(boxx, boxy, boxw, captionh) && !popup_mouseon && mouse_left_pressed)
				window_busy = "viewclickcaption"
		}
		
		if (window_busy = "viewclickcaption")
		{
			if (mouse_move > 10)
			{
				view_main.location = "full"
				window_busy = "viewmove"
				view_glow_ani = 0
				view_glow_location_prev = ""
			}
			else if (!mouse_left)
				window_busy = ""
		}
		
		if (window_busy = "viewmove")
		{
			var mouselocation = "";
			
			// Find new location
			if (mouse_x < view_area_x + view_area_width * 0.3)
				mouselocation = "left"
			
			if (mouse_x > view_area_x + view_area_width * 0.7)
				mouselocation = "right"
			
			if (mouse_y < view_area_y + view_area_height * 0.3)
				mouselocation += "_top"
			
			else if (mouse_y >= view_area_y + view_area_height * 0.7)
				mouselocation += "_bottom"
			
			if (mouselocation = "_top")
				mouselocation = "top"
			
			if (mouselocation = "_bottom")
				mouselocation = "bottom"
			
			view_glow_left_top = false
			view_glow_top = false
			view_glow_right_top = false
			view_glow_right = false
			view_glow_right_bottom = false
			view_glow_bottom = false
			view_glow_left_bottom = false
			view_glow_left = false
			
			switch (mouselocation)
			{
				case "left_top": view_glow_left_top = true; break;
				case "top": view_glow_top = true; break;
				case "right_top": view_glow_right_top = true; break;
				case "right": view_glow_right = true; break;
				case "right_bottom": view_glow_right_bottom = true; break;
				case "bottom": view_glow_bottom = true; break;
				case "left_bottom": view_glow_left_bottom = true; break;
				case "left": view_glow_left = true; break;
			}
			
			if (view_glow_location_prev != mouselocation)
				view_glow_ani = 0
			
			view_glow_location_prev = mouselocation
			
			if (!mouse_left)
			{
				if (mouselocation != "")
					view.location = mouselocation
				
				// Set main view
				switch (view.location)
				{
					case "top":
						view_main.location = "bottom"
						break
					
					case "bottom":
						view_main.location = "top"
						break
					
					case "right":
						view_main.location = "left"
						break
					
					case "left":
						view_main.location = "right"
						break
					
					default:
						view_main.location = "full"
						break
				}
				
				window_busy = ""
			}
		}
	}
	else if (window_busy = "viewmove")
	{
		view_glow_ani += 0.035 * delta
		view_glow_ani = clamp(view_glow_ani, 0, 1)
		
		var ani = ceil((view_glow_ani - 16) + (16 * ease("easeoutcirc", view_glow_ani)));
		
		// Draw glow
		if (view_glow_left_top)
			draw_box(view_area_x, view_area_y, view_second.width + ani, view_second.height + ani, false, c_accent, glow_alpha)
		
		if (view_glow_top)
			draw_box(view_area_x, view_area_y, view_area_width, (view_area_height * split) + ani, false, c_accent, glow_alpha)
		
		if (view_glow_right_top)
			draw_box(view_area_x + view_area_width - (view_second.width + ani), view_area_y, view_second.width + ani, view_second.height + ani, false, c_accent, glow_alpha)
		
		if (view_glow_right)
			draw_box(view_area_x + view_area_width - (view_area_width * split) - ani, view_area_y, (view_area_width * split) + 8, view_area_height, false, c_accent, glow_alpha)
		
		if (view_glow_right_bottom)
			draw_box(view_area_x + view_area_width - view_second.width - ani, view_area_y + view_area_height - view_second.height - ani, view_second.width + 8, view_second.height + 8, false, c_accent, glow_alpha)
		
		if (view_glow_bottom)
			draw_box(view_area_x, view_area_y + view_area_height - (view_area_height * split) - ani, view_area_width, (view_area_height * split) + 8, false, c_accent, glow_alpha)
		
		if (view_glow_left_bottom)
			draw_box(view_area_x, view_area_y + view_area_height - view_second.height - ani, view_second.width + ani, view_second.height + 8, false, c_accent, glow_alpha)
		
		if (view_glow_left)
			draw_box(view_area_x, view_area_y, (view_area_width * split) + ani, view_area_height, false, c_accent, glow_alpha)
	}
	
	// Resizing split
	if (mouseonresizesplit && (mouse_cursor = cr_default || content_mouseon))
	{
		var mouselocation = "";
		
		if (view.location = "right" || view.location = "left")
		{
			mouse_cursor = cr_size_we
			mouselocation = "hor"
		}
		else
		{
			mouse_cursor = cr_size_ns
			mouselocation = "ver"
		}
		
		if (mouse_left_pressed)
			window_busy = "viewresizesplit" + mouselocation
	}
	
	// Resize guide
	if (view = view_second)
	{
		var linetop, linebottom, lineleft, lineright;
		linetop = false
		linebottom = false
		lineleft = false
		lineright = false
		
		if (location = "top" && (mouseonresizesplit || window_busy = "viewresizesplitver"))
			linetop = true
		
		if (location = "bottom" && (mouseonresizesplit || window_busy = "viewresizesplitver"))
			linebottom = true
		
		if (location = "left" && (mouseonresizesplit || window_busy = "viewresizesplithor"))
			lineright = true
		
		if (location = "right" && (mouseonresizesplit || window_busy = "viewresizesplithor"))
			lineleft = true
		
		if ((mouseonresizever || mouseonresizehor) || (window_busy = "viewresizeboth" || window_busy = "viewresizever" || window_busy = "viewresizehor"))
		{
			if (location = "left_top")
			{
				lineright = (mouseonresizehor || window_busy = "viewresizehor" || window_busy = "viewresizeboth")
				linetop = (mouseonresizever || window_busy = "viewresizever" || window_busy = "viewresizeboth")
			}
			
			if (location = "right_top")
			{
				lineleft = (mouseonresizehor || window_busy = "viewresizehor" || window_busy = "viewresizeboth")
				linetop = (mouseonresizever || window_busy = "viewresizever" || window_busy = "viewresizeboth")
			}
			
			if (location = "left_bottom")
			{
				lineright = (mouseonresizehor || window_busy = "viewresizehor" || window_busy = "viewresizeboth")
				linebottom = (mouseonresizever || window_busy = "viewresizever" || window_busy = "viewresizeboth")
			}
			
			if (location = "right_bottom")
			{
				lineleft = (mouseonresizehor || window_busy = "viewresizehor" || window_busy = "viewresizeboth")
				linebottom = (mouseonresizever || window_busy = "viewresizever" || window_busy = "viewresizeboth")
			}
		}
		
		if (linetop)
			draw_box(boxx, boxy + boxh - 2, boxw, 4, false, c_hover, a_hover)
		
		if (linebottom)
			draw_box(boxx, boxy - 2, boxw, 4, false, c_hover, a_hover)
		
		if (lineright)
			draw_box(boxx + boxw - 2, boxy, 4, boxh, false, c_hover, a_hover)
		
		if (lineleft)
			draw_box(boxx - 2, boxy, 4, boxh, false, c_hover, a_hover)
	}
	
	// Render info
	if (view.quality = e_view_mode.RENDER)
	{
		var infotext;
		
		if (view_render_real_time)
			infotext = text_get("viewrenderfps", string(fps), max(1, render_samples), project_render_samples)
		else
			infotext = ""
		
		draw_label(infotext, content_x + 17, content_y + content_height - 15, fa_left, fa_bottom, c_black, .5, font_caption)
		draw_label(infotext, content_x + 16, content_y + content_height - 16, fa_left, fa_bottom, fps < 25 ? setting_theme.toast_color[e_toast.NEGATIVE] : c_white, 1, font_caption)
	}
	
	// Background overlay when moving second view
	if (window_busy = "viewmove" && view = view_second)
		draw_box(content_x, content_y, content_width, content_height, false, c_level_middle, .25)
	
	// Mouse on
	view.mouseon = app_mouse_box(boxx, boxy, boxw, boxh)
	if (view.mouseon && view = view_second)
		view_main.mouseon = false
	
	draw_set_alpha(1)
}
