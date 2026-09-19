/// view_update(view, camera)
/// @arg view
/// @arg camera

function view_update(view, cam)
{
	var editcamobj = false;
	
	// Camera object disabled while placing or object locked
	if (cam)
		editcamobj = (place_tl = null && !cam.lock)
		
	// Surface
	view_update_surface(view, cam)
	
	// Click
	if (content_mouseon && (window_busy = "" || window_busy = "place"))
	{
		place_view_mouse = view
		mouse_cursor = cr_handpoint
		if (mouse_left_pressed)
		{
			window_busy = "viewclick"
			window_focus = string(view)
		}
		
		if ((!cam || editcamobj) && mouse_right_pressed)
		{
			view_click_x = display_mouse_get_x()
			view_click_y = display_mouse_get_y()
			window_busy = "viewmovecamera"
			window_focus = string(view)
			if (cam)
				action_tl_select_single(cam)
		}
	}
	
	// Jump to object
	if ((window_busy = "" && content_mouseon) && tl_edit != null && tl_edit != cam && !cam && keybinds[e_keybind.CAM_VIEW_TIMELINE].pressed)
	{
		cam_work_focus = tl_edit.world_pos
		cam_work_focus_last = point3D_copy(cam_work_focus)
		
		camera_work_set_angle()
		cam_work_angle_look_xy = cam_work_angle_xy
		cam_work_angle_look_z = -cam_work_angle_z
		cam_work_zoom_goal = 100
		camera_work_set_from()
		
		cam_work_jump = true
	}
	
	// Mousewheel
	if (((((window_busy = "" || window_busy = "place") && content_mouseon) || (window_busy = "viewrotatecamera" && window_focus = string(view)))) && mouse_wheel <> 0)
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
		// Select or move camera
		if (window_busy = "viewclick")
		{
			mouse_cursor = cr_handpoint
			
			if ((!cam || editcamobj) && mouse_move > 5)
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
			
			if (!mouse_left)
			{
				if (place_tl = null)
				{
					view_click(view, cam)
					window_busy = ""
				}
				else // Stop placing
					app_stop_place()
			}
		}
		
		// Rotate camera
		if (window_busy = "viewrotatecamera")
		{
			if (cam != null)
				render_samples = -1
			
			if (setting_camera_lock_mouse)
				mouse_cursor = cr_none
			
			if (!cam || cam.value[e_value.CAM_ROTATE])
				camera_control_rotate(cam, view_click_x, view_click_y)
			else
				camera_control_move(cam, view_click_x, view_click_y)
			
			if (!mouse_left)
				window_busy = (place_tl != null ? "place" : "")
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
			
			if (setting_camera_lock_mouse)
				mouse_cursor = cr_none
			camera_control_move(cam, view_click_x, view_click_y)
			
			if (!mouse_right)
			{
				camera_work_set_focus()
				window_busy = (place_tl != null ? "place" : "")
			}
		}
		
		// Pan camera
		if (window_busy = "viewpancamera")
		{
			camera_control_pan(cam)
			
			if (!mouse_left)
			{
				camera_work_set_focus()
				window_busy = ""
			}
		}
	}
	
	// Clear busy
	if (window_busy = "viewpathpointclick")
		window_busy = ""
}
