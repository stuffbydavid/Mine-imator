/// action_lib_pc_type_rot_spd_extend(extend)
/// @arg extend

var extend;

if (history_undo)
	extend = history_data.oldval
else if (history_redo)
	extend = history_data.newval
else
{
	extend = argument0
	history_set_var(action_lib_pc_type_rot_spd_extend, ptype_edit.rot_spd_extend, extend, false)
}

ptype_edit.rot_spd_extend = extend
