/// action_toolbar_open_last_backup()

function action_toolbar_open_last_backup()
{
	var fn = project_folder + "\\" + filename_name(project_folder) + ".backup1";
	
	if (!file_exists(fn))
		return 0
	
	action_toolbar_open(fn)
}
