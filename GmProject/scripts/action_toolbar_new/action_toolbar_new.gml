function action_toolbar_new()
{
	if (project_changed)
	{
		var btn = show_message_ext("Mine-imator", text_get("questionconfirmnew", project_name), text_get("questionsave"), text_get("questiondontsave"), text_get("questioncancel"));
		if (btn = 0)
			project_save()
		else if (btn != 1)
			return 0
	}
	
	popup_newproject_clear()
	popup_show(popup_newproject)
}
