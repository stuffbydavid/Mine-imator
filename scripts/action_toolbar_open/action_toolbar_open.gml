/// action_toolbar_open([fn])

if (project_changed)
	if (question(text_get("questionconfirmopen", project_name)))
		project_save()

if (argument_count > 0)
	project_load(argument[0])
else
	project_load()
