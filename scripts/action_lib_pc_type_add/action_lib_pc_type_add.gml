/// action_lib_pc_type_add()

function action_lib_pc_type_add()
{
	if (history_undo)
	{
		with (temp_edit)
			temp_particles_type_remove(save_id_find(history_data.ptype_save_id)) // Remove
	}
	else
	{
		var hobj = null;
		if (!history_redo)
			hobj = history_set(action_lib_pc_type_add)
		
		var ptype;
		with (temp_edit)
			ptype = temp_particles_type_add()
		
		with (hobj)
			ptype_save_id = save_id_get(ptype)
		
		sortlist_add(ptype_list, ptype)
		ptype_edit = ptype
	}
	
	tab_template_editor_particles_preview_restart()
}
