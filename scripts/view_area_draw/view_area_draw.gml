/// view_area_draw()

// Calculate area
view_area_x = panel_area_x + panel_map[?"left"].size_real + panel_map[?"left_secondary"].size_real
view_area_y = panel_area_y + panel_map[?"top"].size_real
view_area_width = panel_area_width - panel_map[?"left"].size_real - panel_map[?"left_secondary"].size_real - panel_map[?"right"].size_real - panel_map[?"right_secondary"].size_real
view_area_height = panel_area_height - panel_map[?"top"].size_real - panel_map[?"bottom"].size_real

// Draw views
view_draw(view_main)
view_draw(view_second)

// Resizing
if (window_busy = "viewresizehor" || window_busy = "viewresizeboth") // Horizontal
{
	mouse_cursor = cr_size_we
	if (string_contains(view_second.location, "left"))
		view_second.width = view_resize_width + (mouse_x - mouse_click_x)
	else
		view_second.width = view_resize_width - (mouse_x - mouse_click_x)
	
	view_second.width = clamp(view_second.width, 200, view_area_width)
	if (!mouse_left)
		window_busy = ""
}

if (window_busy = "viewresizever" || window_busy = "viewresizeboth") // Vertical
{
	mouse_cursor = cr_size_ns
	if (string_contains(view_second.location, "top"))
		view_second.height = view_resize_height + (mouse_y - mouse_click_y)
	else
		view_second.height = view_resize_height - (mouse_y - mouse_click_y)
	
	view_second.height = clamp(view_second.height, 50, view_area_height)
	if (!mouse_left)
		window_busy = ""
}

if (window_busy = "viewresizeboth") // Both
{
	if (view_second.location = "right" || view_second.location = "left_secondary")
		mouse_cursor = cr_size_nesw
	else
		mouse_cursor = cr_size_nwse
}

// Resizing split
if (window_busy = "viewresizesplithor")
{
	mouse_cursor = cr_size_we
	view_split = clamp((mouse_x - view_area_x) / view_area_width, 0.1, 0.9)
	
	if (view_second.location = "right")
		view_split = 1 - view_split
		
	if (!mouse_left)
		window_busy = ""
}

if (window_busy = "viewresizesplitver")
{
	mouse_cursor = cr_size_ns
	view_split = clamp((mouse_y - view_area_y) / view_area_height, 0.1, 0.9)
	
	if (view_second.location = "bottom")
		view_split = 1 - view_split
		
	if (!mouse_left)
		window_busy = ""
}
