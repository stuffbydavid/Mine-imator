/// state_vars_get_value(vars, name)
/// @arg vars
/// @arg name
/// @desc Gets a single (string) value from a variable, null if not set.

function state_vars_get_value(vars, name)
{
	var varslen = array_length(vars);
	
	for (var i = 0; i < varslen; i += 2)
		if (vars[@ i] = name)
			return vars[@ i + 1]
	
	return null
}
