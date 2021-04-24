/// action_lib_pc_type_spd_extend(extend)
/// @arg extend

function action_lib_pc_type_spd_extend(extend)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spd_extend, ptype_edit.spd_extend, extend, false)
	
	ptype_edit.spd_extend = extend
}
