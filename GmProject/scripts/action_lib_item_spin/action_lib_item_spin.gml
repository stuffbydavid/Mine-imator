function action_lib_item_spin(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_spin, temp_edit.item_spin, enabled, false)
	
	temp_edit.item_spin = enabled
}
