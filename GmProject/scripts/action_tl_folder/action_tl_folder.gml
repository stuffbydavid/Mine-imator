/// action_tl_folder()

function action_tl_folder()
{
	if (history_undo)
	{
		if (history_data.folder_parented)
			action_tl_parent(null, 0)

		with (history_data)
		{
			with (save_id_find(spawn_save_id))
			{
				tl_remove_clean()
				instance_destroy()
			}

			history_restore_tl_select()
			for (var t = 0; t < extend_amount; t++)
				with (save_id_find(extend_save_id[t]))
					tree_extend = other.extend_value[t]
		}
	}
	else
	{
		var hobj, tl, par;

		if (history_redo)
			hobj = history_data
		else
		{
			hobj = history_set(action_tl_folder)
			with (hobj)
			{
				history_save_tl_select()
				folder_parented = tl_edit_amount > 0
				folder_shift = keyboard_check(vk_shift)
				extend_amount = 0
			}
		}
		
		tl = new_tl(e_tl_type.FOLDER)
		if (tl_edit != null)
			with (tl)
				tl_set_parent(tl_edit.parent, ds_list_find_index(tl_edit.parent.tree_list, tl_edit))
		
		if (!history_redo)
			hobj.spawn_save_id = save_id_get(tl)
		
		if (hobj.folder_parented)
			action_tl_parent(tl, 0, hobj)

		par = tl.parent
		while (par != app)
		{
			if (!history_redo)
			{
				hobj.extend_save_id[hobj.extend_amount] = par.save_id
				hobj.extend_value[hobj.extend_amount] = par.tree_extend
				hobj.extend_amount++
			}
			par.tree_extend = true
			par = par.parent
		}

		if (!hobj.folder_shift)
			tl_deselect_all()
		with (tl)
		{
			tl_update_recursive_select()
			tl_select()
		}
	}
	
	app_update_tl_edit()
	tl_update_list()
	tl_update_matrix()
	project_update_counts()
}
