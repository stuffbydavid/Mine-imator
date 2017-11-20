/// app_event_game_end()

if (startup_error)
	return false

audio_stop_all()

// Interface ready
if (window_state != "new_assets" && window_state != "load_assets")
{
	if (project_changed)
		if (question(text_get("questionconfirmexit", project_name)))
			project_save()

	settings_save()
}

log("Closing...")

file_delete_lib(log_previous_file)
file_rename_lib(log_file, log_previous_file)
