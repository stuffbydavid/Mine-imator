/// action_build_first_person(enable)
/// @arg enable

function action_build_first_person(enable)
{
	if (enable && !place_build)
		return 0

	if (build_first_person = enable)
		return 0

	build_first_person = enable
	
	if (enable)
	{
		build_first_person_move_speed_scroll = setting_move_speed_scroll
		setting_move_speed_scroll = 1
		// Disable second view on main window
		build_first_person_second = view_second.show && !window_exists(e_window.VIEW_SECOND)
		if (build_first_person_second)
			view_second.show = false

		place_busy = "firstperson"
		window_busy = place_busy
		window_focus = string(view_main)
		
		// Save mouse position
		build_first_person_mouse_previous_x = display_mouse_get_x()
		build_first_person_mouse_previous_y = display_mouse_get_y()
		
		mouse_cursor = cr_none
		window_set_cursor(mouse_cursor)
		window_mouse_set_permission(true)
		window_mouse_set(floor(view_area_x + view_area_width / 2), floor(view_area_y + view_area_height / 2))
		
		build_first_person_mouse_x = display_mouse_get_x()
		build_first_person_mouse_y = display_mouse_get_y()
	}
	else
	{
		setting_move_speed_scroll = build_first_person_move_speed_scroll
		place_busy = ""
		window_busy = place_busy
		
		mouse_cursor = cr_default
		window_set_cursor(mouse_cursor)
		
		// Restore mouse position
		display_mouse_set(build_first_person_mouse_previous_x, build_first_person_mouse_previous_y)
		window_mouse_set_permission(setting_camera_lock_mouse)
		
		if (build_first_person_second)
			view_second.show = true
		
		build_first_person_second = false
		view_main.update_place_surfaces = true
	}

	app_mouse_clear()
}
