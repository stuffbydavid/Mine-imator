function app_event_game_end()
{
	if (startup_error)
		return true
	
	// Interface ready
	if (window_state != "new_assets" && window_state != "load_assets" && !benchmark_mode)
	{
		if (project_changed)
		{
			var btn = show_message_ext("Mine-imator", text_get("question/confirm_exit", project_name), text_get("question/save"), text_get("question/dont_save"), text_get("question/cancel"));
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
