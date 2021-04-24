/// action_lib_pc_type_angle_extend(extend)
/// @arg extend

function action_lib_pc_type_angle_extend(extend)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_angle_extend, ptype_edit.angle_extend, extend, false)
	
	ptype_edit.angle_extend = extend
}
