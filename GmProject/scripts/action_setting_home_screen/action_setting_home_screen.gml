function action_setting_home_screen()
{
	if (project_changed)
	{
		var btn = show_message_ext("Mine-imator", text_get("question/confirm_open", project_name), text_get("question/save"), text_get("question/dont_save"), text_get("question/cancel"));
		if (btn = 0)
			project_save()
		else if (btn != 1)
			return 0
	}
	
	log("Returning to home screen")
	
	window_state = "startup"
	window_busy = ""
	
	settings_menu_ani = 0
	settings_menu_ani_type = ""
	
	context_menu_close()
	popup_close()
}
