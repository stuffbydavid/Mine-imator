function action_lib_pc_type_scale_add_random_max(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale_add_random_max, ptype_edit.scale_add_random_max, ptype_edit.scale_add_random_max * add + value, true)
	
	ptype_edit.scale_add_random_max = ptype_edit.scale_add_random_max * add + value
}
