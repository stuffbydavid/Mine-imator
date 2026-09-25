/// action_lib_text_outline_size(value, add)

function action_lib_text_outline_size(val, add)
{
	var size = clamp(temp_edit.text_outline_size * add + val, 0, 8);
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_outline_size, temp_edit.text_outline_size, size, true)
	temp_edit.text_outline_size = size
	lib_preview.update = true
}
