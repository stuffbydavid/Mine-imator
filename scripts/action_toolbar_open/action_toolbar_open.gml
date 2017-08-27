/// action_toolbar_open()

if (project_changed)
	if (question(text_get("questionconfirmopen", project_name)))
		project_save()

popup_show(popup_open)
