function action_lib_pc_type_scale(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale, ptype_edit.scale, ptype_edit.scale * add + value, true)
	
	ptype_edit.scale = ptype_edit.scale * add + value
}
