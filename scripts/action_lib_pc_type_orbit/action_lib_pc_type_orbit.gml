/// action_lib_pc_type_orbit(orbit)
/// @arg orbit

var orbit;

if (history_undo)
	orbit = history_data.old_value
else if (history_redo)
	orbit = history_data.new_value
else
{
	orbit = argument0
	history_set_var(action_lib_pc_type_orbit, ptype_edit.orbit, orbit, false)
}

ptype_edit.orbit = orbit
