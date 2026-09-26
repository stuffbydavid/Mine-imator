/// action_lib_text_outline(enable)

function action_lib_text_outline(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_outline, temp_edit.text_outline, enable, false)
	temp_edit.text_outline = enable
	lib_preview.update = true
}
