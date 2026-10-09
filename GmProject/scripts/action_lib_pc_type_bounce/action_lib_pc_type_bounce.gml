function action_lib_pc_type_bounce(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_bounce, ptype_edit.bounce, enabled, false)
	
	ptype_edit.bounce = enabled
}
