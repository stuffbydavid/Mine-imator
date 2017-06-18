/// app_update_backup()
	
if (window_busy = "" && project_folder != "" && setting_backup && backup_next && current_time > backup_next)
	project_backup()
