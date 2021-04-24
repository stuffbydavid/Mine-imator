/// history_save_var_start(script, combine)
/// @arg script
/// @arg combine
/// @desc Registering history for saving multiple variables.

function history_save_var_start(script, combine)
{
	var hobj;
	history_pop()
	
	if (combine &&
		history_amount > 0 &&
		history[0].script = script &&
		history[0].save_axis_edit = axis_edit) // Add to existing
	{
		hobj = history[0]
		hobj.first = false
	}
	else
	{
		history_push()
		
		debug("history_save_var_start(" + script_get_name(script) + ", " + string(combine) + ")")
	
		hobj = new_history(script)
		hobj.first = true
		
		history[0] = hobj
	}
	
	hobj.save_var_amount = 0
	
	return hobj
}
