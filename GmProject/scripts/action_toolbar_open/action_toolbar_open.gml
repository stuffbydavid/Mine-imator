/// @arg [filename]

function action_toolbar_open(fn = "")
{
	if (fn != "" && !file_exists_lib(fn))
	{
		error("erroropenprojectexists")
		return 0
	}
	
	if (project_changed)
	{
		var btn = show_message_ext("Mine-imator", text_get("questionconfirmopen", project_name), text_get("questionsave"), text_get("questiondontsave"), text_get("questioncancel"));
		if (btn = 0)
			project_save()
		else if (btn != 1)
			return 0
	}			
	
	project_load(fn)
}
