function action_lib_pc_type_color_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_israndom, ptype_edit.color_israndom, enabled, false)
	
	ptype_edit.color_israndom = enabled
}
