/// block_load_vars(map, string)
/// @arg map
/// @arg string
/// @desc Loads a string of variables into the given map, eg. "foo=true,bar=10"

var map, str, vars;
map = argument0
str = argument1

vars = string_split(str, ",")

for (var i = 0; i < array_length_1d(vars); i++)
{
	var split = string_split(vars[i], "=");
	if (array_length_1d(split) = 1)
		map[?split[0]] = ""
	else
		map[?split[0]] = split[1]
}