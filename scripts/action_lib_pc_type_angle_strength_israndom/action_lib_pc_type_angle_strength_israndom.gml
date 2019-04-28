/// action_lib_pc_type_angle_strength_israndom(israndom)
/// @arg israndom

var israndom;

if (history_undo)
	israndom = history_data.old_value
else if (history_redo)
	israndom = history_data.new_value
else
{
	israndom = argument0
	history_set_var(action_lib_pc_type_angle_strength_israndom, ptype_edit.angle_strength_israndom, israndom, false)
}

ptype_edit.angle_strength_israndom = israndom
