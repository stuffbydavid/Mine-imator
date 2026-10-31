function action_tl_text_aa(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_tl_text_aa, tl_edit.text_aa, enabled, false)
	
	tl_edit.text_aa = enabled
}
