/// action_lib_pc_type_rot_spd_israndom(israndom)
/// @arg israndom

if (history_undo)
    israndom = history_data.oldval
else if (history_redo)
    israndom = history_data.newval
else
{
    israndom = argument0
    history_set_var(action_lib_pc_type_rot_spd_israndom, ptype_edit.rot_spd_israndom[axis_edit], israndom, false)
}
    
ptype_edit.rot_spd_israndom[axis_edit] = israndom
