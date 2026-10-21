function action_lib_pc_type_bounce_factor(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_bounce_factor, ptype_edit.bounce_factor, ptype_edit.bounce_factor * add + value, true)
	
	ptype_edit.bounce_factor = ptype_edit.bounce_factor * add + value
}
