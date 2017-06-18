/// action_lib_pc_type_spawn_rate(value, add)
/// @arg value
/// @arg add

var val, add, addval;
add = false

if (history_undo)
    val = history_data.oldval
else if (history_redo)
    val = history_data.newval
else
{
    val = argument0
    add = argument1
    history_set_var(action_lib_pc_type_spawn_rate, ptype_edit.spawn_rate * 100, ptype_edit.spawn_rate * add * 100 + val, true)
}

if (add)
    addval = val / 100
else
    addval = val / 100 - ptype_edit.spawn_rate

ptype_edit.spawn_rate += addval
with (temp_edit)
{
    temp_particles_update_spawn_rate(ptype_edit, addval)
    temp_particles_restart()
}
