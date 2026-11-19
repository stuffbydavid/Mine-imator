function action_lib_item_bounce(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_bounce, temp_edit.item_bounce, enabled, false)
	
	temp_edit.item_bounce = enabled
}
