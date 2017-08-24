/// minecraft_asset_get_name(type, name)
/// @arg type
/// @arg name
/// @desc Gets a name from the translation file. If it doesn't exist,
///		  return a formatted version of its key.

var type, name;
type = argument0
name = argument1

if (string_digits(name) = name || !text_exists(type + name))
	return string_format_snakecase(name)
else
	return text_get(type + name)