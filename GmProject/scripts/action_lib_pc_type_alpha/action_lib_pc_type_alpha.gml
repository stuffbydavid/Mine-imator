/// action_lib_pc_type_alpha(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_alpha(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha, ptype_edit.alpha * 100, ptype_edit.alpha * add * 100 + val, true)
	
	ptype_edit.alpha = ptype_edit.alpha * add + val / 100
}
