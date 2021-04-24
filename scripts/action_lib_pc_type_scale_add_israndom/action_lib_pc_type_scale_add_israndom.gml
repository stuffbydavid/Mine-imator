/// action_lib_pc_type_scale_add_israndom(israndom)
/// @arg israndom

function action_lib_pc_type_scale_add_israndom(israndom)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_scale_add_israndom, ptype_edit.scale_add_israndom, israndom, false)
	
	ptype_edit.scale_add_israndom = israndom
}
