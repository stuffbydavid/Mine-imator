/// action_lib_pc_type_color_mix_time_random_min(value, add)
/// @arg value
/// @arg add

function action_lib_pc_type_color_mix_time_random_min(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_mix_time_random_min, ptype_edit.color_mix_time_random_min, ptype_edit.color_mix_time_random_min * add + val, true)
	
	ptype_edit.color_mix_time_random_min = ptype_edit.color_mix_time_random_min * add + val
}
