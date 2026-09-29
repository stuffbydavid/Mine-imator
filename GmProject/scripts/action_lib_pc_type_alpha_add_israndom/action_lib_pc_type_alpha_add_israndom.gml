function action_lib_pc_type_alpha_add_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha_add_israndom, ptype_edit.alpha_add_israndom, enabled, true)
	
	ptype_edit.alpha_add_israndom = enabled
}
