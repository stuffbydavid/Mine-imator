function action_lib_pc_type_alpha_add_random_min(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha_add_random_min, ptype_edit.alpha_add_random_min * 100, ptype_edit.alpha_add_random_min * add * 100 + value, true)
	
	ptype_edit.alpha_add_random_min = ptype_edit.alpha_add_random_min * add + value / 100
}
