/// state_vars_set_value(vars, name, value)
/// @arg vars
/// @arg name
/// @arg value

var vars, name, value, varslen;
vars = argument0
name = argument1
value = argument2
varslen = array_length_1d(vars)

for (var i = 0; i < varslen; i += 2)
{
	if (vars[@ i] = name)
	{
		vars[@ i + 1] = value
		return 0
	}
}

vars[@ varslen] = name
vars[@ varslen + 1] = value