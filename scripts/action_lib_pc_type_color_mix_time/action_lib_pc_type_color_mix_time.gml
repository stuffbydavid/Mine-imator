/// action_lib_pc_type_color_mix_time(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_color_mix_time(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_mix_time, ptype_edit.color_mix_time, ptype_edit.color_mix_time * add + val, true)
	
	ptype_edit.color_mix_time = ptype_edit.color_mix_time * add + val
}
