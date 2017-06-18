/// action_tl_deselect_all()

if (history_undo)
{
	with (history_data)
		history_restore_tl_select()
}
else
{
	if (!history_redo)
		with (history_set(action_tl_deselect_all))
			history_save_tl_select()
			
	tl_deselect_all()
}

app_update_tl_edit()
