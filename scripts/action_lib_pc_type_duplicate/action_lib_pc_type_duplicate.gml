/// action_lib_pc_type_duplicate()

if (history_undo)
{
	with (temp_edit)
		temp_particles_type_remove(iid_find(history_data.copy)) // Remove
}
else
{
	var hobj, copy;
	hobj = null
	
	if (!history_redo)
		hobj = history_set(action_lib_pc_type_duplicate) 
		
	with (temp_edit)
		copy = temp_particles_type_duplicate(ptype_edit)
		
	with (hobj)
		id.copy = iid_get(copy)
	
	sortlist_add(ptype_list, copy)
	ptype_edit = copy
}

tab_template_editor_particles_preview_restart()
