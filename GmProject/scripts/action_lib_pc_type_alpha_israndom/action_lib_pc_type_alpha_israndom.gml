function action_lib_pc_type_alpha_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha_israndom, ptype_edit.alpha_israndom, enabled, false)
	
	ptype_edit.alpha_israndom = enabled
}
