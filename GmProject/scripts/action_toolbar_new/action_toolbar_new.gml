function action_toolbar_new()
{
	if (project_changed)
	{
		var btn = show_message_ext("Mine-imator", text_get("question/confirm_new", project_name), text_get("question/save"), text_get("question/dont_save"), text_get("question/cancel"));
		if (btn = 0)
			project_save()
		else if (btn != 1)
			return 0
	}
	
	popup_newproject_clear()
	popup_show(popup_newproject)
}
