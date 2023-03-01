/// state_vars_match_state_id(vars, block, stateid)
/// @arg vars
/// @arg block
/// @arg stateid
/// @desc Returns whether the collection of variables matches the given state ID.

function state_vars_match_state_id(vars, block, stateid)
{
	var varslen = array_length(vars);
	
	for (var i = 0; i < varslen; i += 2)
	{
		var name, val, valcomp;
		name = vars[@ i]
		val = vars[@ i + 1]
		valcomp = block_get_state_id_value(block, stateid, name)
		
		// Check match
		if (is_array(val)) // OR
		{
			if (!array_contains(val, valcomp))
				return false
		}
		else if (val != valcomp)
			return false
	}
	
	return true
}
