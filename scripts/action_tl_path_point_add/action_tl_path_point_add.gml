/// action_tl_path_point_add()

function action_tl_path_point_add()
{
	if (history_undo)
	{
		with (history_data)
		{
			with (save_id_find(spawn_save_id))
			{
				if (object_index = obj_timeline)
					tl_remove_clean()
				
				instance_destroy()
			}
			
			history_restore_tl_select()
		}
	}
	else
	{
		var hobj, tl;
		hobj = null
		
		if (!history_redo)
			hobj = history_set(action_tl_path_point_add)
	}
	
	if (!history_undo)
	{
		if (!history_redo)
			with (hobj)
				history_save_tl_select()
		
		tl = new_tl(e_tl_type.PATH_POINT)
		
		if (tl_edit != null)
		{
			with (tl)
				tl_set_parent(tl_edit)
		}
		
		tl_deselect_all()
		with (tl)
			tl_select()
		
		if (!history_redo)
		{
			with (hobj)
			{
				history_save_tl_select_new()
				spawn_save_id = tl.save_id
			}
		}
	}
	
	app_update_tl_edit()
	tl_update_list()
	tl_update_matrix()
}