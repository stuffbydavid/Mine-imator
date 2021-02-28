/// toolbar_draw()

var padding, cellsize, resizemouseon;
var offx, offy;
var boxx, boxy, boxw, boxh, boxsize;
var buttonsize, buttonimage;
var benchx, benchy, benchimage, benchscale;
var tip;
padding = 5
cellsize = 30

if (window_busy = "toolbarmove")
{
	offx = mouse_x - mouse_click_x
	offy = mouse_y - mouse_click_y
	draw_set_alpha(0.5)
}
else
{
	offx = 0
	offy = 0
}

// Set dimensions
switch (toolbar_location)
{
	case "top":
	case "bottom":
		boxw = window_width
		boxh = toolbar_size
		if (toolbar_location = "top")
		{
			boxx = offx
			boxy = offy
		}
		else
		{
			boxx = offx
			boxy = window_height - boxh + offy
		}
		boxsize = boxh
		content_direction = e_scroll.HORIZONTAL
		break
	
	case "right":
	case "left":
		boxw = toolbar_size
		boxh = window_height
		if (toolbar_location = "left")
		{
			boxx = offx
			boxy = offy
		}
		else
		{
			boxx = window_width - boxw + offx
			boxy = offy
		}
		boxsize = boxw
		content_direction = e_scroll.VERTICAL
		break
}


// Background
draw_box(boxx, boxy, boxw, boxh, false, setting_color_interface, 1)

// Buttons
if (content_direction = e_scroll.HORIZONTAL)
{
	content_x = boxx + boxsize + padding * 2
	content_width = boxw - content_x - padding
	content_height = ((boxh - padding * 2) div cellsize) * cellsize
	content_y = boxy + floor(boxh / 2-content_height / 2)
}
else
{
	content_width = min(4, (boxw - padding * 2) div cellsize) * cellsize
	content_x = boxx + floor(boxw / 2-content_width / 2)
	content_y = boxy + boxsize + padding * 2
	content_height = boxh - content_y - padding
}
content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon)
toolbar_rows = content_height div cellsize

dx = content_x
dy = content_y

tip_set_shortcut(setting_key_new, setting_key_new_control)
toolbar_draw_button("toolbarnewproject", (popup = popup_newproject && popup_switch_from != popup_startup && popup_switch_to != popup_startup), true, icons.NEW_PROJECT, action_toolbar_new)
tip_set_shortcut(setting_key_import_asset, setting_key_import_asset_control)
toolbar_draw_button("toolbarimportasset", false, true, icons.IMPORT_ASSET, action_toolbar_import_asset)
tip_set_shortcut(setting_key_open, setting_key_open_control)
toolbar_draw_button("toolbaropenproject", false, true, icons.OPEN_PROJECT, action_toolbar_open)
tip_set_shortcut(setting_key_save, setting_key_save_control)
toolbar_draw_button("toolbarsaveproject", false, true, icons.SAVE_PROJECT, action_toolbar_save)
toolbar_draw_button("toolbarsaveprojectas", (popup = popup_saveas), true, icons.SAVE_PROJECT_AS, action_toolbar_save_as)

toolbar_draw_group(2)
toolbar_draw_button("toolbarexportmovie", (popup = popup_exportmovie), true, icons.EXPORT_MOVIE, action_toolbar_export_movie)
toolbar_draw_button("toolbarexportimage", (popup = popup_exportimage), true, icons.EXPORT_IMAGE, action_toolbar_export_image)

toolbar_draw_group(4)
toolbar_draw_button("toolbarviewsecond", view_second.show, true, icons.VIEW_SECOND, action_toolbar_view_second)
toolbar_draw_button("toolbarsettings", settings.show, true, icons.SETTINGS, action_toolbar_settings)

toolbar_draw_group(1)
tip_set_shortcut(setting_key_undo, setting_key_undo_control)
toolbar_draw_button("toolbarundo", false, (history_pos < history_amount), icons.UNDO, action_toolbar_undo)
tip_set_shortcut(setting_key_redo, setting_key_redo_control)
toolbar_draw_button("toolbarredo", false, (history_pos > 0), icons.REDO, action_toolbar_redo)

// Networking
if (boxsize < 70)
{
	buttonsize = 30
	buttonimage = 0
}
else if (boxsize < 100)
{
	buttonsize = 48
	buttonimage = 1
}
else
{
	buttonsize = 64
	buttonimage = 2
}
padding = 10

if (content_direction = e_scroll.HORIZONTAL)
{
	content_width = 360 + (buttonsize + 2) * (2 + trial_version)
	content_height = boxh - padding * 2
	content_x = boxx + boxw - content_width - padding
	content_y = boxy + padding
	dx = content_x + content_width - buttonsize
	dy = content_y + floor(content_height / 2) - buttonsize / 2
}
else
{
	content_height = 130 + (buttonsize + 2) * (2 + trial_version)
	content_width = boxw - padding * 2
	content_x = boxx + padding
	content_y = boxy + boxh - content_height - padding
	dx = content_x + floor(content_width / 2) - buttonsize / 2
	dy = content_y + content_height - buttonsize
}


// Upgrade
if (trial_version)
{
	if (draw_button_normal("toolbarupgrade", dx, dy, buttonsize, buttonsize, e_button.NO_TEXT, false, false, true, icons.UPGRADE_SMALL + buttonimage))
		action_toolbar_upgrade()
		
	if (content_direction = e_scroll.HORIZONTAL)
		dx -= buttonsize + 2
	else
		dy -= buttonsize + 2
}

// Forums
if (draw_button_normal("toolbarforums", dx, dy, buttonsize, buttonsize, e_button.NO_TEXT, false, false, true, icons.FORUMS_SMALL + buttonimage))
	action_toolbar_forums()

if (content_direction = e_scroll.HORIZONTAL)
	dx -= buttonsize + 2
else
	dy -= buttonsize + 2

// Tutorials
if (draw_button_normal("toolbartutorials", dx, dy, buttonsize, buttonsize, e_button.NO_TEXT, false, false, true, icons.HELP_SMALL + buttonimage))
	action_toolbar_tutorials()

if (content_direction = e_scroll.HORIZONTAL)
	dx -= buttonsize + 2
else
	dy -= buttonsize + 2

// Site
if (draw_button_normal("toolbarwebsite", dx, dy, buttonsize, buttonsize, e_button.NO_TEXT, false, false, true, icons.WEBSITE_SMALL + buttonimage))
	action_toolbar_website()

if (content_direction = e_scroll.HORIZONTAL)
	dx -= padding
else
	dy -= padding

// Resizing and moving
resizemouseon = false
switch (toolbar_location)
{
	case "top":
		draw_gradient(boxx, boxy + boxh, boxw, shadow_size, c_black, shadow_alpha, shadow_alpha, 0, 0)
		if (app_mouse_box(boxx, boxy + boxh - 5, boxw, 5))
		{
			mouse_cursor = cr_size_ns
			resizemouseon = true
		}
		break
	
	case "right":
		draw_gradient(boxx - shadow_size, boxy, shadow_size, boxh, c_black, 0, shadow_alpha, shadow_alpha, 0)
		if (app_mouse_box(boxx, boxy, 5, boxh))
		{
			mouse_cursor = cr_size_we
			resizemouseon = true
		}
		break
	
	case "bottom":
		draw_gradient(boxx, boxy - shadow_size, boxw, shadow_size, c_black, 0, 0, shadow_alpha, shadow_alpha)
		if (app_mouse_box(boxx, boxy, boxw, 5))
		{
			mouse_cursor = cr_size_ns
			resizemouseon = true
		}
		break
	
	case "left":
		draw_gradient(boxx + boxw, boxy, shadow_size, boxh, c_black, shadow_alpha, 0, 0, shadow_alpha)
		if (app_mouse_box(boxx + boxw - 5, boxy, 5, boxh))
		{
			mouse_cursor = cr_size_we
			resizemouseon = true
		}
		break
}

// Start resizing
if (resizemouseon && mouse_left_pressed)
{
	window_busy = "toolbarresize"
	toolbar_resize_size = toolbar_size
}

// Start moving
if (app_mouse_box(boxx, boxy, boxw, boxh) && mouse_cursor = cr_default && mouse_left_pressed && !popup_mouseon)
{
	window_busy = "toolbarclick"
}

if (window_busy = "toolbarclick")
{
	if (mouse_move > 10)
		window_busy = "toolbarmove"
	else if (!mouse_left)
		window_busy = ""
}

// Moving
if (window_busy = "toolbarmove")
{
	var mouselocation	
	if (mouse_y < window_height * 0.3)
	{
		mouselocation = "top"
		window_glow_top = min(1, window_glow_top + 0.1 * delta)
	}
	else if (mouse_y > window_height * 0.7)
	{
		mouselocation = "bottom"
		window_glow_bottom = min(1, window_glow_bottom + 0.1 * delta)
	}
	else if (mouse_x < window_width * 0.5)
	{
		mouselocation = "left"
		window_glow_left = min(1, window_glow_left + 0.1 * delta)
	}
	else
	{
		mouselocation = "right"
		window_glow_right = min(1, window_glow_right + 0.1 * delta)
	}
	
	if (!mouse_left)
	{
		toolbar_location = mouselocation
		window_busy = ""
	}
}

// Resizing
if (window_busy = "toolbarresize")
{
	switch (toolbar_location)
	{
		case "top":
			toolbar_size = toolbar_resize_size + (mouse_y - mouse_click_y)
			mouse_cursor = cr_size_ns
			break
		
		case "bottom":
			toolbar_size = toolbar_resize_size - (mouse_y - mouse_click_y)
			mouse_cursor = cr_size_ns
			break
			
		case "left":
			toolbar_size = toolbar_resize_size + (mouse_x - mouse_click_x)
			mouse_cursor = cr_size_we
			break
			
		case "right":
			toolbar_size = toolbar_resize_size - (mouse_x - mouse_click_x)
			mouse_cursor = cr_size_we
			break
	}
	
	toolbar_size = clamp(toolbar_size, 36, 160)
	if (!mouse_left)
		window_busy = ""
}
