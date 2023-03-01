/// action_lib_pc_type_alpha_random_min(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_alpha_random_min(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha_random_min, ptype_edit.alpha_random_min * 100, ptype_edit.alpha_random_min * add * 100 + val, true)
	
	ptype_edit.alpha_random_min = ptype_edit.alpha_random_min * add + val / 100
}
