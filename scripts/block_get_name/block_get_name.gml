/// block_get_name(string, type)
/// @arg string
/// @arg type
/// @desc Returns the name of a block, block state or block state value.

var str, type;
str = argument0
type = argument1

if (string_digits(str) = str || !text_exists(type + str))
	return string_format_snakecase(str)
else
	return text_get(type + str)