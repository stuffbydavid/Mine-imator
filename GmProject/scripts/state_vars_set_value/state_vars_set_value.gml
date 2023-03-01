/// state_vars_set_value(vars, name, value)
/// @arg vars
/// @arg name
/// @arg value

function state_vars_set_value(vars, name, value)
{
	var varslen = array_length(vars);
	
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
}
