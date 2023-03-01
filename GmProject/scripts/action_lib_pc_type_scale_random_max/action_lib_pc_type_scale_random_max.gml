/// action_lib_pc_type_scale_random_max(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_scale_random_max(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale_random_max, ptype_edit.scale_random_max, ptype_edit.scale_random_max * add + val, true)
	
	ptype_edit.scale_random_max = ptype_edit.scale_random_max * add + val
}
