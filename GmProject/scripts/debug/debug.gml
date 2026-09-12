/// debug(string, [value1, value2, value3...])
/// @arg string
/// @arg [value1
/// @arg value2
/// @arg value3...]

function debug()
{
	var cap, valstr;
	
	if (!dev_mode)
		return argument[argument_count - 1]
	
	cap = string_repeat("\t", debug_indent) + string(argument[0])
	valstr = ""
	
	// Values
	if (argument_count > 1)
	{
		valstr = ": "
		for (var a = 1; a < argument_count; a++)
		{
			valstr += string(argument[a])
			if (a < argument_count - 1)
				valstr += ", "
		}
	}
	
	// Debug message
	show_debug_message(cap + valstr)
	
	return argument[argument_count - 1]
}
