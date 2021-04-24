/// action_lib_duplicate()
/// @desc Duplicates the library template.

function action_lib_duplicate()
{
	if (history_undo)
	{
		with (save_id_find(history_data.temp_save_id))
			instance_destroy()
	}
	else
	{
		var hobj, temp;
		hobj = null
		
		if (!history_redo)
			hobj = history_set(action_lib_duplicate)
		
		with (temp_edit)
			temp = temp_duplicate()
		
		with (hobj)
			temp_save_id = save_id_get(temp)
		
		sortlist_add(lib_list, temp)
		temp_edit = temp
	}
	
	tab_template_editor_update_ptype_list()
	lib_preview.update = true
}
