/// action_lib_pc_type_orbit(orbit)
/// @arg orbit

function action_lib_pc_type_orbit(orbit)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_orbit, ptype_edit.orbit, orbit, false)
	
	ptype_edit.orbit = orbit
}
