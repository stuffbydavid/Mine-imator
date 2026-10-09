function shortcut_bar_update()
{
	if (shortcut_bar_state != shortcut_bar_state_prev)
	{
		ds_list_clear(shortcut_bar_list)
		
		if (shortcut_bar_state = "viewport" || shortcut_bar_state = "viewport/camera")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "view/select")
			shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "view/select_part")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.CLICK_LEFT, "view/select_add")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.CLICK_RIGHT, "view/select_part_add")
			
			if (shortcut_bar_state = "viewport")
				shortcut_bar_add(keybinds[e_keybind.CAM_VIEW_TIMELINE].keybind, null, "view/view_object")
			
			shortcut_bar_add(null, e_mouse.DRAG_LEFT, "view/orbit")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "view/pan")
			shortcut_bar_add(null, e_mouse.SCROLL, "view/zoom")
			shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "view/walk")
		}
		
		if (shortcut_bar_state = "viewport/build")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "build/remove")
			shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "build/place")
			shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.SCROLL, "build/scroll")
			shortcut_bar_add(keybind_new("T"), null, "build/search")
			shortcut_bar_add(keybinds[e_keybind.CAM_VIEW_TIMELINE].keybind, null, "build/view_structure")
			shortcut_bar_add(null, e_mouse.DRAG_LEFT, "view/orbit")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "view/pan")
			shortcut_bar_add(null, e_mouse.SCROLL, "view/zoom")
			shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "view/walk")
			shortcut_bar_add(keybind_new("S"), null, "build/reset_structure")
			shortcut_bar_add(keybind_new("F"), null, "build/first_person")
		}

		if (shortcut_bar_state = "camera_move" || shortcut_bar_state = "tl_camera_move" || shortcut_bar_state = "first_person")
		{
			if (shortcut_bar_state = "first_person")
			{
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "build/remove")
				shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "build/place")
				shortcut_bar_add(null, e_mouse.SCROLL, "build/scroll")
				shortcut_bar_add(keybind_new("T"), null, "build/search")
			}
			
			shortcut_bar_add(keybinds[e_keybind.CAM_FORWARD].keybind, null, "view/forward")
			shortcut_bar_add(keybinds[e_keybind.CAM_LEFT].keybind, null, "view/left")
			shortcut_bar_add(keybinds[e_keybind.CAM_BACK].keybind, null, "view/back")
			shortcut_bar_add(keybinds[e_keybind.CAM_RIGHT].keybind, null, "view/right")
			shortcut_bar_add(keybinds[e_keybind.CAM_ASCEND].keybind, null, "view/ascend")
			shortcut_bar_add(keybinds[e_keybind.CAM_DESCEND].keybind, null, "view/descend")
			shortcut_bar_add(keybinds[e_keybind.CAM_FAST].keybind, null, "view/faster")
			shortcut_bar_add(keybinds[e_keybind.CAM_SLOW].keybind, null, "view/slower")
			
			if (shortcut_bar_state = "camera_move" && window_state != "world_import")
				shortcut_bar_add(null, e_mouse.SCROLL, "view/speed")
			
			if (shortcut_bar_state = "tl_camera_move")
			{
				shortcut_bar_add(keybinds[e_keybind.CAM_ROLL_FORWARD].keybind, null, "view/roll_forward")
				shortcut_bar_add(keybinds[e_keybind.CAM_ROLL_BACK].keybind, null, "view/roll_back")
				shortcut_bar_add(keybinds[e_keybind.CAM_ROLL_RESET].keybind, null, "view/roll_reset")
			}
			else if (shortcut_bar_state = "first_person")
				shortcut_bar_add(keybind_new(vk_escape), null, "first_person/cancel")
			
			else if (window_state != "world_import")
				shortcut_bar_add(keybinds[e_keybind.CAM_RESET].keybind, null, "view/reset")
		}
		
		if (string_contains(shortcut_bar_state, "timeline"))
		{
			if (shortcut_bar_state = "timeline/keyframes")
			{
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "tl/keyframe/select")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.CLICK_LEFT, "tl/keyframe/select_add")
				shortcut_bar_add(null, e_mouse.DRAG_LEFT, "tl/keyframe/select_group")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "tl/keyframe/select_group_add")
				shortcut_bar_add(keybinds[e_keybind.KEYFRAMES_STRETCH].keybind, e_mouse.DRAG_LEFT, "tl/keyframe/stretch")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.CLICK_LEFT, "tl/keyframe/deselect")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.DRAG_LEFT, "tl/keyframe/deselect_group")
			}
			
			if (shortcut_bar_state = "timeline/names")
			{
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "tl/timeline/select")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.CLICK_LEFT, "tl/timeline/select_add")
				shortcut_bar_add(null, e_mouse.DRAG_LEFT, "tl/timeline/select_group")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "tl/timeline/select_group_add")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.CLICK_LEFT, "tl/timeline/deselect")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.DRAG_LEFT, "tl/timeline/deselect_group")
			}
			
			if (shortcut_bar_state = "timeline/scale")
			{
				shortcut_bar_add(keybind_new(vk_enter), null, "tl/keyframe/scale_apply")
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "tl/keyframe/scale_apply")
				shortcut_bar_add(keybind_new(vk_escape), null, "tl/keyframe/scale_cancel")
				shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "tl/keyframe/scale_cancel")
			}
			
			if (shortcut_bar_state = "timeline/bar")
			{
				shortcut_bar_add(null, e_mouse.DRAG_LEFT, "tl/set_time")
				shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "tl/set_region")
			}
			
			shortcut_bar_add(null, e_mouse.SCROLL, "list/scroll_vertical")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.SCROLL, "list/scroll_horizontal")
			shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.SCROLL, "view/zoom")
		}
		
		if (shortcut_bar_state = "world_import")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "world/create_selection")
			shortcut_bar_add(null, e_mouse.DRAG_LEFT, "view/orbit")
			shortcut_bar_add([ null, false, false, true ], null, "world/ignore_selection")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "view/pan")
			shortcut_bar_add(null, e_mouse.SCROLL, "view/zoom")
			shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "view/walk")
		}
		if (shortcut_bar_state = "world_import/selection")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "world/finish_selection")
			shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "world/clear_selection")
		}
	}
	
	shortcut_bar_state_prev = shortcut_bar_state
	shortcut_bar_state = ""
}
