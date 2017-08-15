/// block_vars_match(vars, varscomp)
/// @arg vars
/// @arg varscomp
/// @desc Returns whether two collections of variables are matching.

var vars, varscomp, curvar;
vars = argument0
varscomp = argument1

curvar = ds_map_find_first(vars)
while (!is_undefined(curvar))
{
	// Not set
	if (is_undefined(varscomp[?curvar]))
		return false
	
	// Check match
	if (is_array(vars[?curvar])) // OR
	{
		if (!array_contains(vars[?curvar], varscomp[?curvar]))
			return false
	}
	else if (vars[?curvar] != varscomp[?curvar])
		return false
						
	// Next variable
	curvar = ds_map_find_next(vars, curvar)
}

return true