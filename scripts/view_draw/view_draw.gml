/// view_draw(view)
/// @arg view

var view, cam, camname;
var captionx, captiony, captionw, captionh;
var boxx, boxy, boxw, boxh;
var padding, dx, dy;
var renderbuttonsize, renderbuttonpadding, renderbuttonicon, renderbuttonx, renderbuttony, renderbuttonmouseon;
var location, split, mouseonresizesplit, mouseonresizehor, mouseonresizever;

view = argument0

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

switch (location)
{	
	case "top":
		boxh -= view_area_height * split
		mouseonresizesplit = app_mouse_box(boxx, boxy + boxh - 5, boxw, 5)
		break
		
	case "right":
		boxx += view_area_width * split
		boxw -= view_area_width * split
		mouseonresizesplit = app_mouse_box(boxx, boxy, 5, boxh)
		break
		
	case "bottom":
		boxy += view_area_height * split
		boxh -= view_area_height * split
		mouseonresizesplit = app_mouse_box(boxx, boxy, boxw, 5)
		break
		
	case "left":
		boxw -= view_area_width * split
		mouseonresizesplit = app_mouse_box(boxx + boxw - 5, boxy, 5, boxh)
		break
		
	case "right_top":
		boxw = min(view_area_width, view.width)
		boxh = min(view_area_height, view.height)
		boxx += view_area_width - boxw
		mouseonresizehor = app_mouse_box(boxx, boxy, 5, boxh)
		mouseonresizever = app_mouse_box(boxx, boxy + boxh - 5, boxw, 5)
		break
		
	case "right_bottom":
		boxw = min(view_area_width, view.width)
		boxh = min(view_area_height, view.height)
		boxx += view_area_width - boxw
		boxy += view_area_height - boxh
		mouseonresizehor = app_mouse_box(boxx, boxy, 5, boxh)
		mouseonresizever = app_mouse_box(boxx, boxy, boxw, 5)
		break
		
	case "left_bottom":
		boxw = min(view_area_width, view.width)
		boxh = min(view_area_height, view.height)
		boxy += view_area_height - boxh
		mouseonresizehor = app_mouse_box(boxx + boxw - 5, boxy, 5, boxh)
		mouseonresizever = app_mouse_box(boxx, boxy, boxw, 5)
		break
		
	case "left_top":
		boxw = min(view_area_width, view.width)
		boxh = min(view_area_height, view.height)
		mouseonresizehor = app_mouse_box(boxx + boxw - 5, boxy, 5, boxh)
		mouseonresizever = app_mouse_box(boxx, boxy + boxh - 5, boxw, 5)
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
boxw = floor(boxw)
boxh = floor(boxh)

if (boxw < 1 || boxh < 1)
	return 0
	
content_x = boxx
content_y = boxy
content_width = boxw
content_height = boxh
content_mouseon = (view.mouseon && !popup_mouseon)

if (window_busy = "viewmove" && view = view_second)
{
	boxx += mouse_x - mouse_click_x
	boxy += mouse_y - mouse_click_y
	draw_set_alpha(0.5)
}
draw_box(boxx, boxy, boxw, boxh, false, setting_color_background, 1)

// Set camera to use
if (view = view_second)
	cam = timeline_camera
else
	cam = null
	
// Caption
padding = 2
captionx = boxx + padding * 2
captiony = boxy + padding
captionw = boxw
captionh = 24

// Buttons
dw = 16
dh = 16
dx = boxx + boxw - padding - dw - 2
dy = captiony + 2

if (view = view_main && view_second.show && window_busy != "viewmove")
{
	if (view_second.location = "left_top")
		captionx += view_second.width
		
	if (view_second.location = "right_top")
		dx -= view_second.width
	
	if (view_second.location = "left_top" || view_second.location = "right_top")
		captionw -= view_second.width
}

// Close
if (view = view_second)
{
	if (draw_button_normal("viewclose", dx, dy, dw, dh, e_button.NO_TEXT, false, false, true, icons.CLOSE))
	{
		view.show = false
		view_render = false
	}
	dx -= dw + padding
}

// Aspect ratio
if (draw_button_normal("viewaspectratio", dx, dy, dw, dh, e_button.NO_TEXT, view.aspect_ratio, false, true, icons.ASPECT_RATIO))
	view.aspect_ratio = !view.aspect_ratio
dx -= dw + padding

// Grid
if (draw_button_normal("viewgrid", dx, dy, dw, dh, e_button.NO_TEXT, view.grid, false, true, icons.VIEW_GRID))
	view.grid = !view.grid
dx -= dw + padding

// Particles
if (draw_button_normal("viewparticles", dx, dy, dw, dh, e_button.NO_TEXT, view.particles, false, true, icons.PARTICLES))
	view.particles = !view.particles
dx -= dw + padding

// Lights
if (draw_button_normal("viewlights", dx, dy, dw, dh, e_button.NO_TEXT, view.lights, false, true, icons.LIGHT))
	view.lights = !view.lights
dx -= dw + padding

// Controls
if (draw_button_normal("viewcontrols", dx, dy, dw, dh, e_button.NO_TEXT, view.controls, false, true, icons.CONTROLS))
	view.controls = !view.controls
dx -= dw + padding
   
// Camera name
if (!cam)
	camname = text_get("viewworkcamera")
else if (cam.selected)
	camname = text_get("viewselectedcamera", string_remove_newline(cam.display_name))
else
	camname = text_get("viewactivecamera", string_remove_newline(cam.display_name))

draw_label(string_limit(camname, dx - captionx), captionx, captiony + padding, fa_left, fa_top, null, 1, setting_font_bold)
	
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

// Render button
if (view = view_second || !view_second.show)
{
	if (content_height > 250)
	{
		renderbuttonsize = 76
		renderbuttonicon = icons.RENDER_BIG
	}
	else if (content_height > 150)
	{
		renderbuttonsize = 56
		renderbuttonicon = icons.RENDER_MEDIUM
	}
	else if (content_height > 40)
	{
		renderbuttonsize = 38
		renderbuttonicon = icons.RENDER_SMALL
	}
	else
		renderbuttonsize = 0
	
	if (renderbuttonsize > content_width)
		renderbuttonsize = 0
		
	renderbuttonpadding = 5
	renderbuttonx = boxx + boxw - renderbuttonpadding - renderbuttonsize
	renderbuttony = boxy + boxh - renderbuttonpadding - renderbuttonsize
	renderbuttonmouseon = app_mouse_box(renderbuttonx, renderbuttony, renderbuttonsize, renderbuttonsize)
	view.render = view_render
}
else
{
	renderbuttonsize = 0
	renderbuttonmouseon = false
	view.render = false
}

if (content_width > 0 && content_height > 0)
{
	// Match aspect ratio
	if (view.aspect_ratio)
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
			
		draw_box(content_x, content_y, content_width, content_height, false, c_black, 1) // Background
		
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
	content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && view.mouseon && !renderbuttonmouseon && !popup_mouseon)
	
	if (!view.render || view_render_real_time)
		view_update(view, cam)
	else if (window_focus = string(view) && !mouse_left && !mouse_right) // Freeze on slow renders bugfix
		window_busy = ""
	
	draw_surface_size(view.surface, content_x, content_y, content_width, content_height)
	
	if (view.grid)
	{
		var cellwid, cellhei;
		cellwid = content_width / setting_view_grid_size_hor
		cellhei = content_height / setting_view_grid_size_ver
		
		for (var i = 1; i < setting_view_grid_size_hor; i++)
		{
			draw_line_ext(content_x + cellwid * i - 1, content_y, content_x + cellwid * i - 1, content_y + content_height, c_white, 1)
			draw_line_ext(content_x + cellwid * i + 1, content_y, content_x + cellwid * i + 1, content_y + content_height, c_white, 1)
		}
			
		for (var i = 1; i < setting_view_grid_size_ver; i++)
		{
			draw_line_ext(content_x, content_y + cellhei * i - 1, content_x + content_width, content_y + cellhei * i - 1, c_white, 1)
			draw_line_ext(content_x, content_y + cellhei * i + 1, content_x + content_width, content_y + cellhei * i + 1, c_white, 1)
		}
	}
}

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
		
		switch (mouselocation)
		{
			case "left_top":
				view_glow_left_top = min(1, view_glow_left_top + 0.1 * delta)
				break
				
			case "top":
				view_glow_top = min(1, view_glow_top + 0.1 * delta)
				break
				
			case "right_top":
				view_glow_right_top = min(1, view_glow_right_top + 0.1 * delta)
				break
				
			case "right":
				view_glow_right = min(1, view_glow_right + 0.1 * delta)
				break
				
			case "right_bottom":
				view_glow_right_bottom = min(1, view_glow_right_bottom + 0.1 * delta)
				break
				
			case "bottom":
				view_glow_bottom = min(1, view_glow_bottom + 0.1 * delta)
				break
				
			case "left_bottom":
				view_glow_left_bottom = min(1, view_glow_left_bottom + 0.1 * delta)
				break
				
			case "left":
				view_glow_left = min(1, view_glow_left + 0.1 * delta)
				break
		}
		
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
	view_glow_left_top = max(0, view_glow_left_top - 0.05 * delta)
	view_glow_top = max(0, view_glow_top - 0.05 * delta)
	view_glow_right_top = max(0, view_glow_right_top - 0.05 * delta)
	view_glow_right = max(0, view_glow_right - 0.05 * delta)
	view_glow_right_bottom = max(0, view_glow_right_bottom - 0.05 * delta)
	view_glow_bottom = max(0, view_glow_bottom - 0.05 * delta)
	view_glow_left_bottom = max(0, view_glow_left_bottom - 0.05 * delta)
	view_glow_left = max(0, view_glow_left - 0.05 * delta)
	
	// Draw glow
	if (view_glow_left_top > 0)
		draw_box(view_area_x, view_area_y, view_second.width, view_second.height, false, c_yellow, view_glow_left_top * glow_alpha)
		
	if (view_glow_top > 0)
		draw_gradient(view_area_x, view_area_y, view_area_width, 100, c_yellow, view_glow_top, view_glow_top, 0, 0)
		
	if (view_glow_right_top > 0)
		draw_box(view_area_x + view_area_width - view_second.width, view_area_y, view_second.width, view_second.height, false, c_yellow, view_glow_right_top * glow_alpha)
		
	if (view_glow_right > 0)
		draw_gradient(view_area_x + view_area_width - 100, view_area_y, 100, view_area_height, c_yellow, 0, view_glow_right, view_glow_right, 0)
		
	if (view_glow_right_bottom > 0)
		draw_box(view_area_x + view_area_width - view_second.width, view_area_y + view_area_height - view_second.height, view_second.width, view_second.height, false, c_yellow, view_glow_right_bottom * glow_alpha)
		
	if (view_glow_bottom > 0)
		draw_gradient(view_area_x, view_area_y + view_area_height - 100, view_area_width, 100, c_yellow, 0, 0, view_glow_bottom, view_glow_bottom)
		
	if (view_glow_left_bottom > 0)
		draw_box(view_area_x, view_area_y + view_area_height - view_second.height, view_second.width, view_second.height, false, c_yellow, view_glow_left_bottom * glow_alpha)
		
	if (view_glow_left > 0)
		draw_gradient(view_area_x, view_area_y, 100, view_area_height, c_yellow, view_glow_left, 0, 0, view_glow_left)
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

// Render button
content_x = boxx
content_y = boxy + captionh
content_width = boxw
content_height = boxh - captionh

if (renderbuttonsize > 0)
{
	content_mouseon = (renderbuttonmouseon && !popup_mouseon)
	draw_box(renderbuttonx, renderbuttony, renderbuttonsize, renderbuttonsize, false, c_black, 0.25)
	tip_set_shortcut(setting_key_render, setting_key_render_control)
	
	if (draw_button_normal("viewrender", renderbuttonx, renderbuttony, renderbuttonsize, renderbuttonsize, e_button.NO_TEXT, false, false, true, renderbuttonicon))
		view_toggle_render()
}

// Render info
if (view.render)
{
	var infopadding, infox, infoy, infow, infoh, infotext;
	
	draw_set_font(setting_font_big)
	
	if (view_render_real_time)
		infotext = text_get("viewrenderfps", string(fps))
	else
		infotext = text_get("viewrendertime", string_format(render_time / 1000, 1, 2))
	
	infopadding = 5
	infow = string_width(infotext) + 10
	infoh = 35
	
	if (infow + infopadding * 2 < content_width - renderbuttonsize && infoh + infopadding * 2 < content_height)
	{
		infox = boxx + infopadding
		infoy = boxy + boxh - infoh - infopadding
		
		draw_box(infox, infoy, infow, infoh, false, c_black, 0.25)
		draw_label(infotext, infox + infopadding, infoy + infopadding, fa_left, fa_top, c_white, 1)
	}
	
	draw_set_font(setting_font)
}

// Mouse on
view.mouseon = app_mouse_box(boxx, boxy, boxw, boxh)
if (view.mouseon && view = view_second)
	view_main.mouseon = false
	
draw_set_alpha(1)
