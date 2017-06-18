/// action_lib_animate()

if (history_undo)
{
	with (iid_find(history_data.tl))
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
		id.tl = iid_get(tl)
}

tl_update_list()
tl_update_matrix()
