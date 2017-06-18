/// action_lib_pc_spawn_constant(constant)
/// @arg constant

var constant;

if (history_undo)
    constant = history_data.oldval
else if (history_redo)
    constant = history_data.newval
else
{
    constant = argument0
    history_set_var(action_lib_pc_spawn_constant, temp_edit.pc_spawn_constant, constant, false)
}
    
with (temp_edit)
{
    pc_spawn_constant = constant
    temp_particles_restart()
}
