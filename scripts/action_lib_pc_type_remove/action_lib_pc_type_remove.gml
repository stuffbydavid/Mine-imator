/// action_lib_pc_type_remove()

if (history_undo)
{
	with (history_data)
		ptype_edit = history_restore_ptype(save_ptype, temp_edit) // Restore deleted type
	with (temp_edit)
		temp_particles_update_spawn_rate(ptype_edit, ptype_edit.spawn_rate)
	tab_template_editor_update_ptype_list()
}
else
{
	var ptype;
	
	if (history_redo)
		ptype = iid_find(history_data.save_ptype.iid) // Fetch deleted iid from data
	else
	{
		ptype = ptype_edit
		with (history_set(action_lib_pc_type_remove))
			save_ptype = history_save_ptype(ptype) // Save data
	}
	
	with (temp_edit)
		temp_particles_type_remove(ptype)
}

with (temp_edit)
	temp_particles_restart()
