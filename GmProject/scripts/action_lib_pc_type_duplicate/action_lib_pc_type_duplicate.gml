/// action_lib_pc_type_duplicate()

function action_lib_pc_type_duplicate()
{
	if (history_undo)
	{
		with (obj_edit)
			temp_particles_type_remove(save_id_find(history_data.copy_save_id)) // Remove
	}
	else
	{
		var hobj, copy;
		hobj = null
		
		if (!history_redo)
			hobj = history_set(action_lib_pc_type_duplicate) 
		
		with (obj_edit)
			copy = temp_particles_type_duplicate(ptype_edit)
		
		with (hobj)
			copy_save_id = save_id_get(copy)
		
		sortlist_add(ptype_list, copy)
		ptype_edit = copy
	}
	
	project_update_counts()
	tab_object_editor_particles_preview_restart()
}
