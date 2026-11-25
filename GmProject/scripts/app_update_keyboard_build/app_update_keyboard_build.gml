/// @desc Handles build shortcuts and returns whether further shortcuts should be skipped.

function app_update_keyboard_build()
{
	if (!place_build)
		return false

	// Build hotbar shortcuts
	if (!textbox_isediting && window_state = "" && window_busy = place_busy &&
		!popup_mouseon && !context_menu_mouseon && popup_ani_type = "" && window_has_focus())
	{
		var hotbar, slots;
		hotbar = build_hotbars.list.list[|build_hotbars.selected]
		slots = array_length(hotbar.blocks)

		if (!keyboard_check(vk_control) && !keyboard_check(vk_shift) && !keyboard_check(vk_alt))
		{
			for (var i = 0; i < 10; i++)
			{
				if (keyboard_check_pressed(ord("0") + ((i + 1) mod 10)))
				{
					if (keyboard_check(ord("C")))
					{
						if (i < 9)
							action_build_hotbar_save(i)
					}
					else if (keyboard_check(ord("X")))
					{
						if (i < 9 && i < ds_list_size(build_hotbars.list.list))
						{
							action_build_hotbars_list(build_hotbars.list.list[|i])
							sortlist_view(build_hotbars.list, build_hotbars.list.list[|i], false)
							window_focus = string(view_main)
						}
					}
					else if (i < slots)
						action_build_hotbar_select(i)
					
					return true
				}
			}
		}

		if (mouse_wheel != 0)
		{
			if (keyboard_check(vk_control))
			{
				action_build_scroll()
				mouse_wheel = 0
			}
			else if (keyboard_check(vk_alt))
			{
				action_build_state_scroll(sign(mouse_wheel))
				mouse_wheel = 0
			}
			else if (build_first_person || view_main.hotbar_mouseon)
			{
				if (slots > 0)
					action_build_hotbar_select(mod_fix(build_hotbar_slot + sign(mouse_wheel), slots))
				
				mouse_wheel = 0
			}
		}
	}

	// First-person build shortcuts
	if (build_first_person)
	{
		if (keyboard_check_pressed(ord("T")) && !cam_work_moving)
		{
			action_build_search()
			return true
		}
		
		if (keybinds[e_keybind.BUILD_TOOL].pressed)
		{
			action_toolbar_build_mode()
			return true
		}
		
		if (keybinds[e_keybind.UNDO].pressed)
			action_toolbar_undo()
		
		if (keybinds[e_keybind.REDO].pressed)
			action_toolbar_redo()
		
		if (keyboard_check_pressed(vk_escape) || keybinds[e_keybind.BUILD_FIRST_PERSON].pressed)
		{
			if (build_first_person_exit)
				action_toolbar_build_mode()
			else
				action_build_first_person(false)
			return true
		}
		
		return true
	}

	// Build mode shortcuts
	if (!textbox_isediting && window_busy = "")
	{
		if (keybinds[e_keybind.BUILD_FIRST_PERSON].pressed)
		{
			action_build_first_person(true)
			return true
		}

		if (keyboard_check_pressed(vk_escape) || keybinds[e_keybind.BUILD_TOOL].pressed)
		{
			action_toolbar_build_mode()
			return true
		}
		
		if (!keyboard_check(vk_control) && !keyboard_check(vk_alt))
		{
			if (keyboard_check_pressed(ord("S")))
			{
				action_build_structure(null, true)
				return true
			}
		
			if (keyboard_check_pressed(ord("T")))
			{
				action_build_search()
				return true
			}
		}
	}

	return false
}
