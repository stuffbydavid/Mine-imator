/// history_set(script, [buildaction])
/// @arg script
/// @arg [buildaction]
/// @desc Registering history for a generic action.

function history_set(script, buildaction = false)
{
	var hobj;
	
	history_pop()
	history_push()
	
	log("Action", script_get_name(script))
	
	hobj = new_history(script)
	hobj.build_action = buildaction
	
	history[0] = hobj
	
	return hobj
}
