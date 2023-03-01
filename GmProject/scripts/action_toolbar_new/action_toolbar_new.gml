/// action_toolbar_new()

function action_toolbar_new()
{
	if (project_changed)
	{
		var res = show_message_ext("Mine-imator", text_get("questionconfirmnew", project_name), text_get("questionsave"), text_get("questiondontsave"), text_get("questioncancel"));
		if (res == 0)
			project_save()
		else if (res != 1)
			return;
	}
	
	popup_newproject_clear()
	popup_show(popup_newproject)
}
