/// block_vars_string_to_map(string, map)
/// @arg string
/// @arg map
/// @desc Loads a string of comma-separated variables and their
///		  values into the given map, eg. "foo=true,bar=10".

var str, map, vars;
str = argument0
map = argument1

vars = string_split(str, ",")

for (var i = 0; i < array_length_1d(vars); i++)
{
	var split = string_split(vars[i], "=");
	if (array_length_1d(split) = 1)
		map[?split[0]] = ""
	else
		map[?split[0]] = split[1]
}