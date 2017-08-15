/// state_vars_get_value(vars, name)
/// @arg vars
/// @arg name
/// @desc Gets a single (string) value from a variable, "" if not set.

var vars, name, pos;
vars = argument0
name = argument1

pos = string_pos(name + "=", vars)
if (pos = 0)
	return ""

vars = string_delete(vars, 1, pos + string_length(name))

return string_copy(vars, 1, string_pos(",", vars + ",") - 1)