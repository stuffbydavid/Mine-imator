function action_lib_text_halign(halign)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_halign, temp_edit.text_halign, halign, false)
	
	temp_edit.text_halign = halign
	lib_preview.update = true
}
