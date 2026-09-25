/// action_lib_text_outline_color(color)

function action_lib_text_outline_color(color)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_text_outline_color, temp_edit.text_outline_color, color, true)
	temp_edit.text_outline_color = color
	lib_preview.update = true
}
