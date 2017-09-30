/// state_vars_match(vars, varscomp)
/// @arg vars
/// @arg varscomp
/// @desc Returns whether all the values in vars are equal to varscomp.

var vars, varscomp, varslen, curvar;
vars = argument0
varscomp = argument1
varslen = array_length_1d(vars)

for (var i = 0; i < varslen; i += 2)
{
	var name, val, valcomp;
	name = vars[@ i]
	val = vars[@ i + 1]
	valcomp = state_vars_get_value(varscomp, name)
	
	if (valcomp = null) // Not set
		return false
		
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