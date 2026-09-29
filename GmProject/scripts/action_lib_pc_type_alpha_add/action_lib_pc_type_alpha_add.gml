function action_lib_pc_type_alpha_add(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha_add, ptype_edit.alpha_add * 100, ptype_edit.alpha_add * add * 100 + value, true)
	
	ptype_edit.alpha_add = ptype_edit.alpha_add * add + value / 100
}
