/// @desc Registering history for a generic action.

function history_set(script)
{
	history_pop()
	history_push()
	
	//log("Action", script_get_name(script))
	
	var hobj = new_history(script);
	history[0] = hobj
	
	return hobj
}
