/// shortcut_bar_update()

function shortcut_bar_update()
{
	if (shortcut_bar_state != shortcut_bar_state_prev)
	{
		ds_list_clear(shortcut_bar_list)
		
		if (shortcut_bar_state = "viewport" || shortcut_bar_state = "viewportcam")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "viewselect")
			
			if (shortcut_bar_state = "viewport")
				shortcut_bar_add(keybinds[e_keybind.CAM_VIEW_TIMELINE].keybind, null, "viewviewobject")
			
			shortcut_bar_add(null, e_mouse.DRAG_LEFT, "vieworbit")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "viewpan")
			shortcut_bar_add(null, e_mouse.SCROLL, "viewzoom")
			shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "viewwalk")
		}
		
		if (shortcut_bar_state = "buildviewport")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "buildremove")
			shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "buildplace")
			shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.SCROLL, "buildscroll")
			shortcut_bar_add(keybind_new("E"), null, "buildsearch")
			shortcut_bar_add(keybinds[e_keybind.CAM_VIEW_TIMELINE].keybind, null, "buildviewstructure")
			shortcut_bar_add(null, e_mouse.DRAG_LEFT, "vieworbit")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "viewpan")
			shortcut_bar_add(null, e_mouse.SCROLL, "viewzoom")
			shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "viewwalk")
			shortcut_bar_add(keybind_new("S"), null, "buildresetstructure")
			shortcut_bar_add(keybind_new("F"), null, "buildfirstperson")
		}

		if (shortcut_bar_state = "cameramove" || shortcut_bar_state = "tlcameramove" || shortcut_bar_state = "firstperson")
		{
			if (shortcut_bar_state = "firstperson")
			{
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "buildremove")
				shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "buildplace")
				shortcut_bar_add(null, e_mouse.SCROLL, "buildscroll")
				shortcut_bar_add(keybind_new("E"), null, "buildsearch")
			}
			
			shortcut_bar_add(keybinds[e_keybind.CAM_FORWARD].keybind, null, "viewforward")
			shortcut_bar_add(keybinds[e_keybind.CAM_LEFT].keybind, null, "viewleft")
			shortcut_bar_add(keybinds[e_keybind.CAM_BACK].keybind, null, "viewback")
			shortcut_bar_add(keybinds[e_keybind.CAM_RIGHT].keybind, null, "viewright")
			shortcut_bar_add(keybinds[e_keybind.CAM_ASCEND].keybind, null, "viewascend")
			shortcut_bar_add(keybinds[e_keybind.CAM_DESCEND].keybind, null, "viewdescend")
			shortcut_bar_add(keybinds[e_keybind.CAM_FAST].keybind, null, "viewfaster")
			shortcut_bar_add(keybinds[e_keybind.CAM_SLOW].keybind, null, "viewslower")
			
			if (shortcut_bar_state = "tlcameramove")
			{
				shortcut_bar_add(keybinds[e_keybind.CAM_ROLL_FORWARD].keybind, null, "viewrollforward")
				shortcut_bar_add(keybinds[e_keybind.CAM_ROLL_BACK].keybind, null, "viewrollback")
				shortcut_bar_add(keybinds[e_keybind.CAM_ROLL_RESET].keybind, null, "viewrollreset")
			}
			else if (shortcut_bar_state = "firstperson")
				shortcut_bar_add(keybind_new(vk_escape), null, "firstpersoncancel")
			
			else if (window_state != "world_import")
				shortcut_bar_add(keybinds[e_keybind.CAM_RESET].keybind, null, "viewreset")
		}
		
		if (string_contains(shortcut_bar_state, "timeline"))
		{
			if (shortcut_bar_state = "timelinekeyframes")
			{
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "tlkeyframeselect")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.CLICK_LEFT, "tlkeyframeselectadd")
				shortcut_bar_add(null, e_mouse.DRAG_LEFT, "tlkeyframeselectgroup")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "tlkeyframeselectgroupadd")
				shortcut_bar_add(keybinds[e_keybind.KEYFRAMES_STRETCH].keybind, e_mouse.DRAG_LEFT, "tlkeyframestretch")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.CLICK_LEFT, "tlkeyframedeselect")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.DRAG_LEFT, "tlkeyframedeselectgroup")
			}
			
			if (shortcut_bar_state = "timelinenames")
			{
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "tltimelineselect")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.CLICK_LEFT, "tltimelineselectadd")
				shortcut_bar_add(null, e_mouse.DRAG_LEFT, "tltimelineselectgroup")
				shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "tltimelineselectgroupadd")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.CLICK_LEFT, "tltimelinedeselect")
				shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.DRAG_LEFT, "tltimelinedeselectgroup")
			}
			
			if (shortcut_bar_state = "timelinescale")
			{
				shortcut_bar_add(keybind_new(vk_enter), null, "tlkeyframescaleapply")
				shortcut_bar_add(null, e_mouse.CLICK_LEFT, "tlkeyframescaleapply")
				shortcut_bar_add(keybind_new(vk_escape), null, "tlkeyframescalecancel")
				shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "tlkeyframescalecancel")
			}
			
			if (shortcut_bar_state = "timelinebar")
			{
				shortcut_bar_add(null, e_mouse.DRAG_LEFT, "tlsettime")
				shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "tlsetregion")
			}
			
			shortcut_bar_add(null, e_mouse.SCROLL, "listscrollvertical")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.SCROLL, "listscrollhorizontal")
			shortcut_bar_add(keybind_new(null, true, false, false), e_mouse.SCROLL, "viewzoom")
		}
		
		if (shortcut_bar_state = "worldimport")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "worldcreateselection")
			shortcut_bar_add(null, e_mouse.DRAG_LEFT, "vieworbit")
			shortcut_bar_add([ null, false, false, true ], null, "worldignoreselection")
			shortcut_bar_add(keybind_new(null, false, true, false), e_mouse.DRAG_LEFT, "viewpan")
			shortcut_bar_add(null, e_mouse.SCROLL, "viewzoom")
			shortcut_bar_add(null, e_mouse.DRAG_RIGHT, "viewwalk")
		}
		if (shortcut_bar_state = "worldimportselection")
		{
			shortcut_bar_add(null, e_mouse.CLICK_LEFT, "worldfinishselection")
			shortcut_bar_add(null, e_mouse.CLICK_RIGHT, "worldclearselection")
		}
	}
	
	shortcut_bar_state_prev = shortcut_bar_state
	shortcut_bar_state = ""
}
