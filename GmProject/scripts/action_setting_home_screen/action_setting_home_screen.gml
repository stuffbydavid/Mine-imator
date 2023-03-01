/// action_setting_home_screen()

function action_setting_home_screen()
{
	if (project_changed)
	{
		var res = show_message_ext("Mine-imator", text_get("questionconfirmopen", project_name), text_get("questionsave"), text_get("questiondontsave"), text_get("questioncancel"));
		if (res == 0)
			project_save()
		else if (res != 1)
			return 0;
	}
	
	log("Returning to home screen")
	project_reset()
	
	window_state = "startup"
	window_busy = ""
	settings_menu_ani = 0
	settings_menu_ani_type = ""
	context_menu_close()
	popup_close()
}
