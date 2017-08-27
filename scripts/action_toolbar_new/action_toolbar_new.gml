/// action_toolbar_new()

if (project_changed)
	if (question(text_get("questionconfirmnew", project_name)))
		project_save()
		
popup_newproject_clear()
popup_show(popup_newproject)
