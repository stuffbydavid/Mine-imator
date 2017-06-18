/// string_pos_ext(substr, str, startpos)
/// @arg substr
/// @arg str
/// @arg startpos

var substr, str, startpos;
substr = argument0
str = argument1
startpos = argument2

return string_pos(substr, string_delete(str, 1, startpos)) + startpos