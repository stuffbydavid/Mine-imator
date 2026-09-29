function app_event_game_end()
{
	if (startup_error)
		return true
	
	// Interface ready
	if (window_state != "new_assets" && window_state != "load_assets" && !benchmark_mode)
	{
		if (project_changed)
		{
			var btn = show_message_ext("Mine-imator", text_get("questionconfirmexit", project_name), text_get("questionsave"), text_get("questiondontsave"), text_get("questioncancel"));
			if (btn = 0)
				project_save()
			else if (btn != 1)
				return false
		}
		
		settings_save()
	}

	audio_stop_all()
	
	log("Closing...")
	
	return true
}
