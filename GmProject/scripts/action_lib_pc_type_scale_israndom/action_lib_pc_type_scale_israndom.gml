function action_lib_pc_type_scale_israndom(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale_israndom, ptype_edit.scale_israndom, enabled, false)
	
	ptype_edit.scale_israndom = enabled
}
