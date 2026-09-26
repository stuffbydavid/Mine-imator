/// app_update_tl_edit()

function app_update_tl_edit()
{
	app_update_tl_edit_tabs()
	app_update_tl_edit_select()
	
	if (obj_edit = null || !instance_exists(obj_edit))
	{
		obj_edit = null
		tab_close(object_editor)
		return 0
	}
}
