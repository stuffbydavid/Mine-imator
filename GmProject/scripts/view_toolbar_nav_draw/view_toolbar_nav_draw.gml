/// @arg view
/// @arg x
/// @arg y

function view_toolbar_nav_draw(view, xx, yy)
{
	// Can't make the options work if the main view is a camera object, oh well
	if (view.camera != null)
		return 0
	
	var width, height, starty, padding;
	width = 32
	height = view.toolbar_nav_height
	starty = yy
	padding = 4
	
	if (yy + height > content_y + content_height)
	{
		view.toolbar_nav_mouseon = bench_button_hover
		return 0
	}
	
	microani_prefix = string(view)
	
	if ((app_mouse_box(xx, yy, width, height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon)) || bench_button_hover)
		view.toolbar_nav_mouseon = true
	else
		view.toolbar_nav_mouseon = false
	
	if (view.toolbar_nav_mouseon)
		content_mouseon = true
	
	if (app_mouse_box(xx - 64, yy - 64, width + 128, height + 128) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon))
		view.toolbar_nav_alpha_goal = 1
	else
		view.toolbar_nav_alpha_goal = .8
	
	if (window_busy = "view/move_camera_toggle" || window_busy = "view/zoom_camera" || window_busy = "view/pan_camera")
		view.toolbar_nav_alpha_goal = 1
	//else if (window_busy = "bench")
	//	view.toolbar_nav_alpha_goal = .8
	
	draw_set_alpha(view.toolbar_nav_alpha)
	
	draw_dropshadow(xx, yy, width, height, c_black, 1)
	draw_box(xx, yy, width, height, false, c_level_top, 1)
	draw_outline(xx, yy, width, height, 1, c_border, a_border, true)
	
	xx += 4
	yy += 4
	
	tip_force = "left"
	
	// Walk navigation toggle
	//tip_set_keybind(e_keybind.CAM_WALK)
	if (draw_button_icon("view/tool/walknav", xx, yy, 24, 24, window_busy = "view/move_camera_toggle", icons.WALK, null, false, "tooltip/nav/walk"))
	{
		if (window_busy != "view/move_camera_toggle")
		{
			window_focus = string(view)
			window_busy = "view/move_camera_toggle"
			view_click_x = display_mouse_get_x()
			view_click_y = display_mouse_get_y()
		}
	}
	yy += 24 + padding
	
	// Zoom
	draw_button_icon("view/tool/zoom", xx, yy, 24, 24, window_busy = "view/zoom_camera", icons.ZOOM_IN, null, false, "tooltip/nav/zoom")
	if (current_microani.holding.value && window_busy != "view/zoom_camera")
	{
		window_focus = string(view)
		window_busy = "view/zoom_camera"
		//view_click_x = display_mouse_get_x()
		//view_click_y = display_mouse_get_y()
	}
	yy += 24 + padding
	
	// Pan
	draw_button_icon("view/tool/pan", xx, yy, 24, 24, window_busy = "view/pan_camera", icons.PAN, null, false, "tooltip/nav/pan")
	if (current_microani.holding.value && window_busy != "view/pan_camera")
	{
		window_focus = string(view)
		window_busy = "view/pan_camera"
		//view_click_x = display_mouse_get_x()
		//view_click_y = display_mouse_get_y()
	}
	yy += 24 + padding
	
	tip_force = ""
	
	view.toolbar_nav_height = yy - starty
	microani_prefix = ""
	
	draw_set_alpha(1)
}
