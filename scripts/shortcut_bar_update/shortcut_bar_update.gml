/// shortcut_bar_update()
// keybinds_map[?argument0].keybind

if (shortcut_bar_state != shortcut_bar_state_prev)
{
	ds_list_clear(shortcut_bar_list)
	
	if (shortcut_bar_state = "viewport")
	{
		shortcut_bar_add(null, e_mouse.CLICK_LEFT, "select")
		shortcut_bar_add(null, e_mouse.DRAG_LEFT, "orbit")
		shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "pan")
		shortcut_bar_add(null, e_mouse.SCROLL, "zoom")
		shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "walk")
	}
	
	if (shortcut_bar_state = "cameramove" || shortcut_bar_state = "tlcameramove")
	{
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_FORWARD].keybind, null, "forward")
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_LEFT].keybind, null, "left")
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_BACK].keybind, null, "back")
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_RIGHT].keybind, null, "right")
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_ASCEND].keybind, null, "ascend")
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_DESCEND].keybind, null, "descend")
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_FAST].keybind, null, "faster")
		shortcut_bar_add(keybinds_map[?e_keybind.CAM_SLOW].keybind, null, "slower")
		
		if (shortcut_bar_state = "tlcameramove")
		{
			shortcut_bar_add(keybinds_map[?e_keybind.CAM_ROLL_FORWARD].keybind, null, "rollforward")
			shortcut_bar_add(keybinds_map[?e_keybind.CAM_ROLL_BACK].keybind, null, "rollback")
			shortcut_bar_add(keybinds_map[?e_keybind.CAM_ROLL_RESET].keybind, null, "rollreset")
		}
		else
			shortcut_bar_add(keybinds_map[?e_keybind.CAM_RESET].keybind, null, "reset")
	}
	
	if (shortcut_bar_state = "timeline")
	{
		shortcut_bar_add(null, e_mouse.SCROLL, "scrollhorizontal")
		shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.SCROLL, "scrollvertical")
		shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.SCROLL, "zoom")
	}
}

shortcut_bar_state_prev = shortcut_bar_state
shortcut_bar_state = ""
