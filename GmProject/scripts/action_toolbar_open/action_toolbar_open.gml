/// @arg [filename]

function action_toolbar_open(fn = "")
{
	if (fn != "" && !file_exists_lib(fn))
	{
		error("error/open_project_exists")
		return 0
	}
	
	if (project_changed)
	{
		var btn = show_message_ext("Mine-imator", text_get("question/confirm_open", project_name), text_get("question/save"), text_get("question/dont_save"), text_get("question/cancel"));
		if (btn = 0)
			project_save()
		else if (btn != 1)
			return 0
	}			
	
	project_load(fn)
}
