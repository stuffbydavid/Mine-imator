function action_lib_pc_type_color_mix_time(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_color_mix_time, ptype_edit.color_mix_time, ptype_edit.color_mix_time * add + value, true)
	
	ptype_edit.color_mix_time = ptype_edit.color_mix_time * add + value
}
