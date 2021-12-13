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
		if (question(text_get("questionconfirmopen", project_name)))
			project_save()					
	
	if (argument_count > 0)
		project_load(argument[0])
	else
		project_load()
}
