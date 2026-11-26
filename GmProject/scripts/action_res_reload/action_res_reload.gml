function action_res_reload()
{
	var hobj = null;
	
	if (!history_undo && !history_redo)
	{
		load_folder = project_folder
		save_folder = project_folder
		
		with (res_edit)
			res_load(true)
		
		hobj = history_set(action_res_reload)
		with (hobj)
		{
			part_amount = 0
			part_child_amount = 0
			
			history_save_tl_select()
		}
		
		tl_deselect_all()
	}
	
	res_update_reload(hobj)
}
