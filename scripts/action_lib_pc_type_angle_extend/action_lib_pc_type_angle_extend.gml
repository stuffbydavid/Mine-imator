/// action_lib_pc_type_angle_extend(extend)
/// @arg extend

var extend;

if (history_undo)
	extend = history_data.old_value
else if (history_redo)
	extend = history_data.new_value
else
{
	extend = argument0
	history_set_var(action_lib_pc_type_angle_extend, ptype_edit.angle_extend, extend, false)
}

ptype_edit.angle_extend = extend
