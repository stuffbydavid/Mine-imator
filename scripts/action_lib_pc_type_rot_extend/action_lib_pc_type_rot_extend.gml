/// action_lib_pc_type_rot_extend(extend)
/// @arg extend

function action_lib_pc_type_rot_extend(extend)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_rot_extend, ptype_edit.rot_extend, extend, false)
	
	ptype_edit.rot_extend = extend
}
