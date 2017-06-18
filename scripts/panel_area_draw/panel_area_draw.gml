/// panel_area_draw()

// Calculate area
panel_area_x = 0
panel_area_y = 0
panel_area_width = window_width
panel_area_height = window_height

tab_move_mouseon_panel = null
tab_move_mouseon_position = 0

if (window_busy != "toolbarmove")
{
	switch (toolbar_location)
	{
		case "top":
			panel_area_y += toolbar_size
			panel_area_height -= toolbar_size
			break
			
		case "left":
			panel_area_x += toolbar_size
			panel_area_width -= toolbar_size
			break
			
		case "bottom":
			panel_area_height -= toolbar_size
			break
			
		case "right":
			panel_area_width -= toolbar_size
			break
	}
}

// Set size
with (obj_panel)
	size_real = size * (tab_list_amount > 0)

// Stop panels overlapping
panel_left_bottom.size_real -= max(0, panel_left_top.size_real + panel_left_bottom.size_real + panel_right_bottom.size_real + panel_right_top.size_real - panel_area_width)
panel_left_top.size_real -= max(0, panel_left_top.size_real + panel_right_top.size_real + panel_right_bottom.size_real - panel_area_width)
panel_bottom.size_real -= max(0, panel_top.size_real + panel_bottom.size_real - panel_area_height)

// Set max size
panel_left_top.size_real = min(panel_left_top.size_real, panel_area_width)
panel_right_top.size_real = min(panel_right_top.size_real, panel_area_width)
panel_top.size_real = min(panel_top.size_real, panel_area_height)
panel_bottom.size_real = min(panel_bottom.size_real, panel_area_height)

// Draw views
view_area_draw()

// Draw panels
panel_draw(panel_left_bottom)
panel_draw(panel_right_bottom)
panel_draw(panel_bottom)
panel_draw(panel_top)
panel_draw(panel_left_top)
panel_draw(panel_right_top)

// Resizing
if (window_busy = "panelresize")
{
	if (panel_resize = panel_left_top || panel_resize = panel_left_bottom)
	{
		mouse_cursor = cr_size_we
		panel_resize.size = max(300, panel_resize_size + (mouse_x - mouse_click_x))
	}
	else if (panel_resize = panel_right_top || panel_resize = panel_right_bottom)
	{
		mouse_cursor = cr_size_we
		panel_resize.size = max(300, panel_resize_size - (mouse_x - mouse_click_x))
	}
	else if (panel_resize = panel_bottom)
	{
		mouse_cursor = cr_size_ns
		panel_resize.size = max(50, panel_resize_size - (mouse_y - mouse_click_y))
	}
	else if (panel_resize = panel_top)
	{
		mouse_cursor = cr_size_ns
		panel_resize.size = max(50, panel_resize_size + (mouse_y - mouse_click_y))
	}
	if (!mouse_left)
		window_busy = ""
}

// Moving
if (window_busy = "tabmove")
{
	panel_move_draw()
	
	// Find panel
	if (tab_move_mouseon_panel = null)
	{
		// Calculate sizes of the boxes to check
		var toph, bottomh, lefttopw, leftbottomw, righttopw
		toph = view_area_height
		bottomh = view_area_height
		lefttopw = view_area_width
		leftbottomw = view_area_width
		righttopw = view_area_width
		
		// Top panel
		if (!panel_left_top.size_real || !panel_left_bottom.size_real || !panel_right_top.size_real || !panel_right_bottom.size_real)
			toph *= 0.33
		else if (!panel_bottom.size_real)
			toph *= 0.5
			
		// Bottom panel
		if (!panel_left_top.size_real || !panel_left_bottom.size_real || !panel_right_top.size_real || !panel_right_bottom.size_real)
			bottomh *= 0.33
		else if (!panel_top.size_real)
			bottomh *= 0.5
			
		// Left top
		if (!panel_right_top.size_real || !panel_right_bottom.size_real)
			lefttopw *= 0.5
		if (!panel_left_bottom.size_real)
			lefttopw *= 0.5
			
		// Left bottom
		if (!panel_right_top.size_real || !panel_right_bottom.size_real)
			leftbottomw *= 0.5
			
		// Right top
		if (!panel_left_top.size_real || !panel_left_bottom.size_real)
			righttopw *= 0.5
		if (!panel_right_bottom.size_real)
			righttopw *= 0.5		
		
		if (mouse_y <= view_area_y + toph && !panel_top.size_real)
			tab_move_mouseon_panel = panel_top
		else if (mouse_y >= view_area_y + view_area_height - bottomh && !panel_bottom.size_real)
			tab_move_mouseon_panel = panel_bottom
		else if (mouse_x <= view_area_x + lefttopw && !panel_left_top.size_real)
			tab_move_mouseon_panel = panel_left_top
		else if (mouse_x <= view_area_x + leftbottomw && !panel_left_bottom.size_real)
			tab_move_mouseon_panel = panel_left_bottom
		else if (mouse_x >= view_area_x + view_area_width - righttopw && !panel_right_top.size_real)
			tab_move_mouseon_panel = panel_right_top
		else
			tab_move_mouseon_panel = panel_right_bottom
			
		tab_move_mouseon_panel.glow = min(1, tab_move_mouseon_panel.glow + 0.1 * delta)
	}
	
	// Let it go
	if (!mouse_left)
	{
		panel_tab_list_add(tab_move_mouseon_panel, tab_move_mouseon_position, tab_move)
		window_busy = ""
		
		with (obj_tab)
			glow = 0
			
		with (obj_panel)
		{
			list_glow = 0
			glow = 0
		}
	}
}
