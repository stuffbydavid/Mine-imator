/// action_lib_pc_spawn_amount(value, add)
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
    history_set_var(action_lib_pc_spawn_amount, temp_edit.pc_spawn_amount, temp_edit.pc_spawn_amount * add + val, true)
}

with (temp_edit)
{
    pc_spawn_amount = pc_spawn_amount * add + val
    temp_particles_restart()
}
