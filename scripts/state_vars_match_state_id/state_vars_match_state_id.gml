/// state_vars_match(vars, block, stateid)
/// @arg vars
/// @arg block
/// @arg stateid
/// @desc Returns whether the collection of variables matches the given state ID.

var vars, block, stateid, varslen;
vars = argument0
block = argument1
stateid = argument2
varslen = array_length_1d(vars)

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