/// action_lib_text_aa(enable)

function action_lib_text_aa(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_aa, temp_edit.text_aa, enable, false)
	temp_edit.text_aa = enable
	lib_preview.update = true
}
