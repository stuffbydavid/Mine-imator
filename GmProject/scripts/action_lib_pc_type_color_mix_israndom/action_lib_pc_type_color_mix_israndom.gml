/// action_lib_pc_type_color_mix_israndom(israndom)
/// @arg israndom

function action_lib_pc_type_color_mix_israndom(israndom)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_mix_israndom, ptype_edit.color_mix_israndom, israndom, false)
	
	ptype_edit.color_mix_israndom = israndom
}
