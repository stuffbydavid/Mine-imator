/// app_event_game_end()

if (startup_error)
    return false

audio_stop_all()
if (project_changed)
    if (question(text_get("questionconfirmexit", project_name)))
        project_save("")

settings_save()
recent_save()
closed_alerts_save()

log("Closing...")

file_delete_lib(log_previous_file)
file_rename_lib(log_file, log_previous_file)
