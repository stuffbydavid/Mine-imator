function action_lib_pc_type_alpha_add_random_max(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha_add_random_max, ptype_edit.alpha_add_random_max * 100, ptype_edit.alpha_add_random_max * add * 100 + value, true)
	
	ptype_edit.alpha_add_random_max = ptype_edit.alpha_add_random_max * add + value / 100
}
