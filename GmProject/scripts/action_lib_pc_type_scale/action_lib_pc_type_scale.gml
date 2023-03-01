/// action_lib_pc_type_scale(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_scale(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale, ptype_edit.scale, ptype_edit.scale * add + val, true)
	
	ptype_edit.scale = ptype_edit.scale * add + val
}
