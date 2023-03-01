/// action_toolbar_open([fn])
/// @arg [fn]

function action_toolbar_open()
{
	if (argument_count > 0 && !file_exists_lib(argument[0]))
	{
		error("erroropenprojectexists")
		return 0
	}
	
	if (project_changed)
	{
		var res = show_message_ext("Mine-imator", text_get("questionconfirmopen", project_name), text_get("questionsave"), text_get("questiondontsave"), text_get("questioncancel"));
		if (res == 0)
			project_save()
		else if (res != 1)
			return 0;
	}			
	
	if (argument_count > 0)
		project_load(argument[0])
	else
		project_load()
}
