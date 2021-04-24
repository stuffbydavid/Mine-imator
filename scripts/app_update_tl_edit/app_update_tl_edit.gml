/// app_update_tl_edit()

function app_update_tl_edit()
{
	app_update_tl_edit_tabs()
	app_update_tl_edit_select()
	
	if (!instance_exists(temp_edit))
	{
		tab_close(template_editor)
		return 0
	}
}
