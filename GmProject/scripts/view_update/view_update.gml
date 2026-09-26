/// view_update(view, camera)
/// @arg view
/// @arg camera

function view_update(view, cam)
{
	var editcamobj = false;
	
	// Camera object disabled while placing or object locked
	if (cam)
		editcamobj = (place_tl = null && !place_build && !cam.lock)
		
	// Surface
	view_update_surface(view, cam)

	// First-person build controls
	if (place_build && build_first_person && view = view_main)
	{
		place_content_mouseon = view
		mouse_cursor = cr_none
		shortcut_bar_state = "firstperson"
		camera_control_move(cam, build_first_person_mouse_x, build_first_person_mouse_y)
		view.update_place_surfaces = true

		if (mouse_wheel <> 0)
			action_build_scroll()

		if (mouse_left_pressed)
			action_build_remove()
		
		else if (mouse_right_pressed && place_pos != null)
			action_build_place()

		if (!window_has_focus())
			action_build_first_person(false)

		return 0
	}
	
	// Click
	if (content_mouseon && (window_busy = "" || window_busy = place_busy))
	{
		place_content_mouseon = view
		mouse_cursor = cr_handpoint
		
		if (mouse_left_pressed)
		{
			window_busy = "viewclick"
			window_focus = string(view)
			view_click_type = e_mouse.CLICK_LEFT
		}
		
		if (mouse_right_pressed)
		{
			window_busy = "viewclick"
			window_focus = string(view)
			view_click_type = e_mouse.CLICK_RIGHT
		}
		
		if (mouse_middle_pressed)
		{
			window_busy = "viewclick"
			window_focus = string(view)
			view_click_type = e_mouse.CLICK_MIDDLE
		}
	}
	
	// Jump to object or build structure
	var focustl = place_build ? build_structure : tl_edit;
	if ((window_busy = "" && content_mouseon) && focustl != null && instance_exists(focustl) && focustl != cam && !cam && keybinds[e_keybind.CAM_VIEW_TIMELINE].pressed)
	{
		tl_focus = focustl
		cam_work_focus = focustl.world_pos
		cam_work_focus_last = point3D_copy(cam_work_focus)
		
		camera_work_set_angle()
		cam_work_angle_look_xy = cam_work_angle_xy
		cam_work_angle_look_z = -cam_work_angle_z
		cam_work_zoom_goal = 100
		camera_work_set_from()
		
		cam_work_jump = true
	}
	
	// Mousewheel
	if (mouse_wheel <> 0 &&
		(!keyboard_check(vk_control) || !place_build) &&
		(((window_busy = "" || window_busy = place_busy) && content_mouseon) ||
		 (window_busy = "viewrotatecamera" && window_focus = string(view))))
	{
		if (!cam)
			cam_work_zoom_goal = clamp(cam_work_zoom_goal * (1 + 0.25 * mouse_wheel), cam_near, cam_far)
		else if (cam.value[e_value.CAM_ROTATE] && editcamobj)
		{
			action_tl_select_single(cam)
			if (cam.cam_goalzoom < 0) // Reset
				cam.cam_goalzoom = cam.value[e_value.CAM_ROTATE_DISTANCE]
			cam.cam_goalzoom = max(1, cam.cam_goalzoom * (1 + 0.25 * mouse_wheel))
		}
	}
	
	if (window_focus = string(view))
	{
		if (!cam && (window_busy = "viewrotatecamera" || window_busy = "viewmovecamera") && keybinds[e_keybind.CAM_RESET].pressed)
			setting_move_speed_scroll = 1

		// Select or move camera
		if (window_busy = "viewclick")
		{
			mouse_cursor = cr_handpoint
			if (place_build && cam = null)
				shortcut_bar_state = "buildviewport"
			else
				shortcut_bar_state = "viewport" + (cam = null ? "" : "cam")
			
			if ((!cam || editcamobj) && mouse_move > 5)
			{
				if (view_click_type = e_mouse.CLICK_RIGHT)
				{
					view_click_x = display_mouse_get_x()
					view_click_y = display_mouse_get_y()
					window_busy = "viewmovecamera"
					if (cam)
						action_tl_select_single(cam)
				}
				else if (view_click_type = e_mouse.CLICK_LEFT)
				{
					if (keyboard_check(vk_shift))
					{
						window_busy = "viewpancamera"
						window_focus = string(view)
					
						if (cam)
							action_tl_select_single(cam)
					}
					else
					{
						view_click_x = display_mouse_get_x()
						view_click_y = display_mouse_get_y()
						window_busy = "viewrotatecamera"
						if (cam)
							action_tl_select_single(cam)
					}
				}
				else if (view_click_type = e_mouse.CLICK_MIDDLE)
				{
					view_click_x = display_mouse_get_x()
					view_click_y = display_mouse_get_y()
					window_busy = "viewfovcamera"
					if (cam)
						action_tl_select_single(cam)
				}
			}
			
			if (
				(view_click_type = e_mouse.CLICK_RIGHT && !mouse_right) ||
				(view_click_type = e_mouse.CLICK_LEFT && !mouse_left) ||
				(view_click_type = e_mouse.CLICK_MIDDLE && !mouse_middle)
			)
			{
				if (place_build)
				{
					window_busy = place_busy
					if (view_click_type = e_mouse.CLICK_RIGHT)
					{
						if (place_pos != null)
							action_build_place()
					}
					else
						action_build_remove()
				}
				else if (place_tl = null)
				{
					view_click(view, cam, view_click_type = e_mouse.CLICK_RIGHT)
					window_busy = ""
				}
				else // Stop placing
					app_stop_place(true)
			}
		}
		
		// Rotate camera
		if (window_busy = "viewrotatecamera")
		{
			if (place_build && cam = null)
				shortcut_bar_state = "buildviewport"

			if (cam != null)
				render_samples = -1
			
			if (setting_camera_lock_mouse)
				mouse_cursor = cr_none
			
			if (!cam || cam.value[e_value.CAM_ROTATE])
				camera_control_rotate(cam, view_click_x, view_click_y)
			else
				camera_control_move(cam, view_click_x, view_click_y)
			
			if (!mouse_left)
			{
				view.update_place_surfaces = true
				window_busy = (place_build || place_tl != null) ? place_busy : ""
			}
		}
		
		// Move camera
		if (window_busy = "viewmovecamera")
		{
			if (cam = null)
				shortcut_bar_state = "cameramove"
			else
			{
				shortcut_bar_state = "tlcameramove"
				render_samples = -1
			}
			
			// Scroll to slow down movement
			if (mouse_wheel <> 0)
			{
				if (mouse_wheel < 0)
					setting_move_speed_scroll += (setting_move_speed_scroll / 5)
				else
					setting_move_speed_scroll -= (setting_move_speed_scroll / 5)
					
				setting_move_speed_scroll = clamp(setting_move_speed_scroll, 0.01, 10)
			}
			
			if (setting_camera_lock_mouse)
				mouse_cursor = cr_none
			camera_control_move(cam, view_click_x, view_click_y)
			
			if (!mouse_right)
			{
				camera_work_set_focus()
				view.update_place_surfaces = true
				window_busy = (place_build || place_tl != null) ? place_busy : ""
			}
			
		}
		
		// Adjust camera FOV
		if (window_busy = "viewfovcamera")
		{
			if (cam != null)
				render_samples = -1
						
			if (setting_camera_lock_mouse)
				mouse_cursor = cr_none
			camera_control_fov(cam, view_click_x, view_click_y)
			
			if (!mouse_middle)
			{
				view.update_place_surfaces = true
				window_busy = (place_build || place_tl != null) ? place_busy : ""
			}
		}
		
		// Pan camera
		if (window_busy = "viewpancamera")
		{
			if (place_build && cam = null)
				shortcut_bar_state = "buildviewport"

			camera_control_pan(cam)
			
			if (!mouse_left)
			{
				camera_work_set_focus()
				view.update_place_surfaces = true
				window_busy = (place_build || place_tl != null) ? place_busy : ""
			}
		}
	}
	
	// Clear busy
	if (window_busy = "viewpathpointclick")
		window_busy = ""
}
