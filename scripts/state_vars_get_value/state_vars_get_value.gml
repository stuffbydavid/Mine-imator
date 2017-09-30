/// state_vars_get_value(vars, name)
/// @arg vars
/// @arg name
/// @desc Gets a single (string) value from a variable, null if not set.

var vars, name, varslen;
vars = argument0
name = argument1
varslen = array_length_1d(vars)

for (var i = 0; i < varslen; i += 2)
	if (vars[@ i] = name)
		return vars[@ i + 1]

return null