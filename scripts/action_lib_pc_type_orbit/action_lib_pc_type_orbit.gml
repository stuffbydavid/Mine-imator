/// action_lib_pc_type_orbit(orbit)
/// @arg orbit

var orbit;

if (history_undo)
    orbit = history_data.oldval
else if (history_redo)
    orbit = history_data.newval
else
{
    orbit = argument0
    history_set_var(action_lib_pc_type_orbit, ptype_edit.orbit, orbit, false)
}

ptype_edit.orbit = orbit
