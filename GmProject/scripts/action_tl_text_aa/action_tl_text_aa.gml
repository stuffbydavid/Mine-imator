/// action_tl_text_aa(enable)

function action_tl_text_aa(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_tl_text_aa, tl_edit.text_aa, enable, false)
	tl_edit.text_aa = enable
}
