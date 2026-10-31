function action_lib_text_outline(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_outline, temp_edit.text_outline, enabled, false)
	
	temp_edit.text_outline = enabled
	lib_preview.update = true
}
