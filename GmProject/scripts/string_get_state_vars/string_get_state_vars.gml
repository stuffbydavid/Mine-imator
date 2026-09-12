/// string_get_state_vars(string)
/// @arg string
/// @desc Parses a string of comma-separated variables and their values, eg. "foo=true,bar=10".
/// Returns null if invalid.

function string_get_state_vars(str)
{
	var vars, varslen, arr;
	vars = string_split_escaped(str, ",")
	varslen = array_length(vars)
	arr = array_create(varslen * 2)
	
	for (var i = 0; i < varslen; i++)
	{
		var nameval = string_split_escaped(vars[i], "=");
		arr[i * 2] = nameval[0]
		
		if (array_length(nameval) > 1)
			arr[i * 2 + 1] = nameval[1]
		else
			return null
	}
	
	return arr
}
