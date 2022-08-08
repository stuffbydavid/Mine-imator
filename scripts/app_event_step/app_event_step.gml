/// app_event_step()

function app_event_step()
{
	if (dev_mode && !is_cpp()) // Debug windows in GM
	{
		if (keyboard_check_pressed(vk_f1))
			window_debug_current = e_window.MAIN
		
		if (keyboard_check_pressed(vk_f2) && ds_list_size(window_list) > 0)
			window_debug_current = window_list[|0]
				
		if (keyboard_check_pressed(vk_f3) && ds_list_size(window_list) > 1)
			window_debug_current = window_list[|1]
				
		if (keyboard_check_pressed(vk_f4) && ds_list_size(window_list) > 2)
			window_debug_current = window_list[|2]
	}
	
	app_update_window()
	
	if (window_mouse_is_active(window_get_current()))
		app_update_mouse()
	
	if (window_get_current() = e_window.MAIN || (window_get_current() != e_window.MAIN && dev_mode && !is_cpp()))
	{
		textbox_input = keyboard_string
		keyboard_string = ""
		
		app_update_gc()
		app_update_micro_animations()
		
		if (window_state = "load_assets")
			return 0
		
		if (window_state = "new_assets" || window_state = "export_movie")
			return 0
		
		app_update_keybinds()
		app_update_keyboard()
		app_update_play()
		app_update_animate()
		app_update_previews()
		app_update_backup()
		app_update_recent()
		app_update_work_camera()
		
		if (window_get_current() = e_window.MAIN)
			app_update_caption()
		
		app_update_toasts()
		app_update_interface()
		app_update_lists()
		app_update_minecraft_resources()
		
		current_step += 60 / room_speed
	}
}
