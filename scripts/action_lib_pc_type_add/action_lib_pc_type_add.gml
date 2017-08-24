/// action_lib_pc_type_add()


if (history_undo)
{
	with (temp_edit)
		temp_particles_type_remove(save_id_find(history_data.ptype_save_id)) // Remove
}
else
{
	var ptype;
	with (temp_edit)
		ptype = temp_particles_type_add()
		
	if (!history_redo)
	{
		with (history_set(action_lib_pc_type_add))
			ptype_save_id = save_id_get(ptype)
	}
	
	sortlist_add(ptype_list, ptype)
	ptype_edit = ptype
}

tab_template_editor_particles_preview_restart()
