/// action_lib_pc_type_alpha_add(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_alpha_add(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_alpha_add, ptype_edit.alpha_add * 100, ptype_edit.alpha_add * add * 100 + val, true)
	
	ptype_edit.alpha_add = ptype_edit.alpha_add * add + val / 100
}
