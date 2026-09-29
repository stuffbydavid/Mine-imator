function action_lib_pc_type_scale_add(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale_add, ptype_edit.scale_add, ptype_edit.scale_add * add + value, true)
	
	ptype_edit.scale_add = ptype_edit.scale_add * add + value
}
