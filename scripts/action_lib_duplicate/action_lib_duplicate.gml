/// action_lib_duplicate()
/// @desc Duplicates the library template.

if (history_undo)
{
	with (iid_find(history_data.temp))
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
		id.temp = iid_get(temp)
	
	sortlist_add(lib_list, temp)
	temp_edit = temp
}
	
tab_template_editor_update_ptype_list()
lib_preview.update = true
