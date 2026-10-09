/// @arg view
/// @arg camera

function view_update(view, cam)
{
	// Camera object disabled while placing or object locked
	var editcamobj = false, watermark, mousechanged;
	if (cam)
		editcamobj = (place_tl = null && !place_build && !cam.lock)
		
	// Refresh when the viewport size, camera or display options change
	watermark = (
		(settings.show && settings.program.show && setting_watermark_custom && collapse_map[?"settings/watermark"]) ||
		(popup_current && popup_current.name = "export_movie" && popup_exportmovie.watermark) ||
		(popup_current && popup_current.name = "export_image" && popup_exportimage.watermark)
	)
	if (!surface_exists(view.surface) ||
		view.surface_width != content_width || view.surface_height != content_height ||
		view.surface_renderer != view.renderer || view.surface_camera_last != cam ||
		view.surface_particles != view.particles || view.surface_effects != view.effects ||
		view.surface_gizmos_enabled != view.gizmos || view.surface_transparent_background != view.transparent_background ||
		view.surface_watermark != watermark)
	{
		view_changed(view)
	}
	
	// First-person movement continuously refreshes only the main viewport
	if (place_build && build_first_person)
	{
		if (view = view_main)
			view_changed(view)
	}
	
	// Work camera
	else if (!cam && 
		(!vec3_equals(view.surface_work_from, cam_work_from) ||
		view.surface_work_angle[@ X] != cam_work_angle_look_xy || view.surface_work_angle[@ Y] != cam_work_angle_look_z ||
		view.surface_work_angle[@ Z] != cam_work_roll))
	{
		view_changed(view)
	}
	
	// Refresh gizmo hover only when the mouse moves or enters/leaves the view
	mousechanged = (view.surface_mouseon != content_mouseon || (content_mouseon &&
		(view.surface_mouse_x != mouse_x - content_x || view.surface_mouse_y != mouse_y - content_y)))
	
	if (!surface_exists(view.surface_gizmos) ||
		view.surface_tool_move != setting_tool_move || view.surface_tool_rotate != setting_tool_rotate ||
		view.surface_tool_scale != setting_tool_scale || view.surface_tool_bend != setting_tool_bend ||
		view.surface_tool_transform != setting_tool_transform ||
		(view.gizmos && view.surface_control_edit != view_control_edit) ||
		(view.gizmos && mousechanged))
	{
		view.update_gizmos = true
	}
	
	// Picking needs the current view's render state
	if (content_mouseon &&
	    (mouse_left_pressed || mouse_right_pressed || mouse_left_released || mouse_right_released || place_tl != null || place_build))
	{
		view_changed(view)
	}
	
	// Update only the overlay while dragging until object values change
	if (window_busy = "render/control" && view_control_edit_view = view && (!mouse_still || !mouse_left))
		view.update_gizmos = true
	
	// Update surface
	if (view.update)
		view_update_surface(view, cam, watermark)
	
	// Update gizmo surface
	if (view.update_gizmos)
		view_update_gizmos(view, cam)
	
	if (window_busy = "render/control" && view_control_edit_view = view)
		mouse_cursor = cr_handpoint

	// First-person build controls
	if (place_build && build_first_person && view = view_main)
	{
		place_content_mouseon = view
		mouse_cursor = cr_none
		shortcut_bar_state = "first_person"
		
		camera_control_move(cam, build_first_person_mouse_x, build_first_person_mouse_y)
		
		view_changed(view)

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
			window_busy = "view/click"
			window_focus = string(view)
			view_click_right = false
		}
		
		if (mouse_right_pressed)
		{
			window_busy = "view/click"
			window_focus = string(view)
			view_click_right = true
		}
	}
	
	// Jump to object or build structure
	var focustl = place_build ? build_structure : tl_edit;
	if ((window_busy = "" && content_mouseon) && focustl != null && instance_exists(focustl) && focustl.value_type[e_value_type.TRANSFORM_POS] && focustl != cam && !cam && keybinds[e_keybind.CAM_VIEW_TIMELINE].pressed)
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
		 (window_busy = "view/rotate_camera" && window_focus = string(view))))
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
		if (!cam && (window_busy = "view/rotate_camera" || window_busy = "view/move_camera") && keybinds[e_keybind.CAM_RESET].pressed)
			setting_move_speed_scroll = 1

		// Select or move camera
		if (window_busy = "view/click")
		{
			mouse_cursor = cr_handpoint
			
			if (place_build && cam = null)
				shortcut_bar_state = "viewport/build"
			else
				shortcut_bar_state = "viewport" + (cam = null ? "" : "/camera")
			
			if (view_click_right && (!cam || editcamobj) && mouse_move > 5)
			{
				view_click_x = display_mouse_get_x()
				view_click_y = display_mouse_get_y()
				window_busy = "view/move_camera"
				
				if (cam)
					action_tl_select_single(cam)
			}
			else if ((!cam || editcamobj) && mouse_move > 5)
			{
				if (keyboard_check(vk_shift))
				{
					window_busy = "view/pan_camera"
					window_focus = string(view)
					
					if (cam)
						action_tl_select_single(cam)
				}
				else
				{
					view_click_x = display_mouse_get_x()
					view_click_y = display_mouse_get_y()
					window_busy = "view/rotate_camera"
					
					if (cam)
						action_tl_select_single(cam)
				}
			}
			
			if ((view_click_right && !mouse_right) || (!view_click_right && !mouse_left))
			{
				if (place_build)
				{
					window_busy = place_busy
					if (view_click_right)
					{
						if (place_pos != null)
							action_build_place()
					}
					else
						action_build_remove()
				}
				else if (place_tl = null)
				{
					view_click(view, cam, view_click_right)
					window_busy = ""
				}
				else // Stop placing
					app_stop_place(true)
			}
		}
		
		// Rotate camera
		if (window_busy = "view/rotate_camera")
		{
			if (place_build && cam = null)
				shortcut_bar_state = "viewport/build"

			if (cam != null)
				render_samples = -1
			
			if (setting_camera_lock_mouse)
				mouse_cursor = cr_none
			
			if (!cam || cam.value[e_value.CAM_ROTATE])
				camera_control_rotate(cam, view_click_x, view_click_y, setting_camera_lock_mouse)
			else
				camera_control_move(cam, view_click_x, view_click_y, setting_camera_lock_mouse)
			
			if (!setting_camera_lock_mouse)
			{
				view_click_x = display_mouse_get_x()
				view_click_y = display_mouse_get_y()
			}
			
			if (!mouse_left)
			{
				view_changed(view)
				window_busy = (place_build || place_tl != null) ? place_busy : ""
			}
		}
		
		// Move camera
		if (window_busy = "view/move_camera")
		{
			if (cam = null)
				shortcut_bar_state = "camera_move"
			else
			{
				shortcut_bar_state = "tl_camera_move"
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
			
			camera_control_move(cam, view_click_x, view_click_y, setting_camera_lock_mouse)
			
			if (!setting_camera_lock_mouse)
			{
				view_click_x = display_mouse_get_x()
				view_click_y = display_mouse_get_y()
			}
			
			if (!mouse_right)
			{
				camera_work_set_focus()
				view_changed(view)
				window_busy = (place_build || place_tl != null) ? place_busy : ""
			}
			
		}
		
		// Pan camera
		if (window_busy = "view/pan_camera")
		{
			if (place_build && cam = null)
				shortcut_bar_state = "viewport/build"

			camera_control_pan(cam)
			
			if (!mouse_left)
			{
				camera_work_set_focus()
				view_changed(view)
				window_busy = (place_build || place_tl != null) ? place_busy : ""
			}
		}
	}
	
	// Clear busy
	if (window_busy = "view/path_point_click")
		window_busy = ""
}
