/// action_lib_text_valign(align)

function action_lib_text_valign(align)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_valign, temp_edit.text_valign, align, false)
	temp_edit.text_valign = align
	lib_preview.update = true
}
