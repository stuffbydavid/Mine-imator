/// action_tl_deselect(timeline)
/// @arg timeline

if (history_undo)
{
	with (history_data)
		history_restore_tl_select()
}
else
{
	var tl;
	
	if (!history_redo)
	{
		tl = argument0
		with (history_set(action_tl_deselect))
		{
			id.tl = tl
			history_save_tl_select()
		}
	}
	else
		tl = history_data.tl

	with (tl)
		tl_deselect()
}
	
app_update_tl_edit()
