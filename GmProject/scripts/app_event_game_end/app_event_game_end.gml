/// app_event_game_end()

function app_event_game_end()
{
	if (startup_error)
		return true
	
	audio_stop_all()
	
	// Interface ready
	if (window_state != "new_assets" && window_state != "load_assets")
	{
		if (project_changed)
		{
			var res = show_message_ext("Mine-imator", text_get("questionconfirmexit", project_name), text_get("questionsave"), text_get("questiondontsave"), text_get("questioncancel"));
			if (res == 0)
				project_save()
			else if (res != 1)
				return false
		}
		
		settings_save()
	}
	
	log("Closing...")
	
	return true
}
