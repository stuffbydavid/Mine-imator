/// action_lib_animate()

if (history_undo)
{
	with (save_id_find(history_data.tl_save_id))
		instance_destroy()
}
else
{
	var hobj, tl;
	hobj = null
	
	if (!history_redo)
		hobj = history_set(action_lib_animate)
			
	with (temp_edit)
		tl = temp_animate()
		
	with (hobj)
		tl_save_id = save_id_get(tl)
}

tl_update_list()
tl_update_matrix()
