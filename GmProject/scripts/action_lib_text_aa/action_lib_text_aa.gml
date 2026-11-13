function action_lib_text_aa(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_aa, temp_edit.text_aa, enabled, false)
	
	temp_edit.text_aa = enabled
	lib_preview.update = true
}
