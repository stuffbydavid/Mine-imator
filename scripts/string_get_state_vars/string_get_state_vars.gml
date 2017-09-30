/// string_get_state_vars(string)
/// @arg string
/// @desc Parses a string of comma-separated variables
///		  and their values, eg. "foo=true,bar=10".

var str = argument0;

var arr, arrlen, vars, varslen;
arr = array()
arrlen = 0
vars = string_split(str, ",")
varslen = array_length_1d(vars)

for (var i = 0; i < varslen; i++)
{
	var nameval = string_split(vars[i], "=");
	arr[arrlen++] = nameval[0]
		
	if (array_length_1d(nameval) > 1)
		arr[arrlen++] = nameval[1]
	else
		arr[arrlen++] = ""
}

return arr