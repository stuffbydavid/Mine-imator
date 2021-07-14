/// draw_keybind(keybindID, x, y)
/// @arg keybindID
/// @arg x
/// @arg y

function draw_keybind(keybindID, xx, yy)
{
	var keyobj, name, mouseon;
	keyobj = keybinds_map[?keybindID]
	name = "settingskey" + keyobj.name
	
	tab_control(28)
	
	if (xx + dw < content_x || xx > content_x + content_width || yy + tab_control_h < content_y || yy > content_y + content_height)
	{
		tab_next(false)
		return 0
	}
	
	mouseon = app_mouse_box(xx, yy, dw, tab_control_h) && content_mouseon
	
	context_menu_area(xx, yy, dw, tab_control_h, "keybind", keybindID, null, null, null)
	
	microani_set(name, null, mouseon || window_busy = name, false, false)
	microani_update(mouseon || window_busy = name, false, false)
	
	draw_label(text_get(name) + ":", dx, dy + (tab_control_h/2), fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	draw_label(text_control_name(window_busy = name ? keybind_edit : keyobj.keybind), dx + dw - (32 * microani_arr[e_microani.HOVER]), dy + (tab_control_h/2), fa_right, fa_middle, c_text_main, a_text_main, font_value)
	
	draw_set_alpha(microani_arr[e_microani.HOVER])
	
	if (draw_button_icon(name + "edit", dx + dw - 24, dy + 2, 24, 24, window_busy = name, icons.PENCIL, null, false, "tooltipeditkeybind"))
	{
		window_busy = name
		keybind_edit = keybind_new(null)
	}
	
	draw_set_alpha(1)
	
	// Detect shortcut changes
	if (window_busy = name)
	{
		var update = false
		
		if (keyboard_check_pressed(vk_anykey) || keyboard_check_released(vk_anykey))
		{
			keybind_edit[e_keybind_key.CTRL] = (keyboard_check_direct(vk_lcontrol) || keyboard_check_direct(vk_rcontrol))
			keybind_edit[e_keybind_key.SHIFT] = (keyboard_check_direct(vk_lshift) || keyboard_check_direct(vk_rshift))
			keybind_edit[e_keybind_key.ALT] = (keyboard_check_direct(vk_lalt) || keyboard_check_direct(vk_ralt))
			
			if (keyboard_check_pressed(vk_anykey))
			{
				var key = keyboard_lastkey;
				keyboard_clear(keyboard_lastkey)
				
				if (key != vk_control && key != vk_lcontrol && key != vk_rcontrol && 
					key != vk_shift && key != vk_lshift && key != vk_rshift && 
					key != vk_alt && key != vk_lalt && key != vk_ralt)
				{
					keybind_edit[e_keybind_key.CHAR] = key
					update = true
				}
			}
		
		}
		
		// Stop recording
		if (mouse_left_pressed)
		{
			update = true
			app_mouse_clear()
		}
		
		if (update)
		{
			window_busy = ""
			
			if (!array_equals(keybind_edit, keybind_new(null)))
				keybind_set(keybindID, keybind_edit)
		}
	}
	
	tab_next(false)
}
