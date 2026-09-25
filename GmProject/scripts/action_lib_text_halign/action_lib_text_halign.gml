/// action_lib_text_halign(align)

function action_lib_text_halign(align)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_halign, temp_edit.text_halign, align, false)
	temp_edit.text_halign = align
	lib_preview.update = true
}
