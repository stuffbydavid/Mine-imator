/// log(string, [ values...])
/// @desc Prints values to the log file
/// @arg string
/// @arg [values...]

function log()
{
	var cap, valstr;
	cap = string(argument[0])
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
	
	log_message(cap + valstr)

	return 1
}
