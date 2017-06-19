/// action_lib_pc_type_color_mix_time(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.oldval
else if (history_redo)
	val = history_data.newval
else
{
	val = argument0
	add = argument1
	history_set_var(action_lib_pc_type_color_mix_time, ptype_edit.color_mix_time, ptype_edit.color_mix_time * add + val, true)
}

ptype_edit.color_mix_time = ptype_edit.color_mix_time * add + val
