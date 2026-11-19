function action_lib_text_valign(valign)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_valign, temp_edit.text_valign, valign, false)
	
	temp_edit.text_valign = valign
	lib_preview.update = true
}
