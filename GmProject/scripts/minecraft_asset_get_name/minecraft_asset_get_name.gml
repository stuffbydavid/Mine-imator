/// minecraft_asset_get_name(type, name)
/// @arg type
/// @arg name
/// @desc Gets a name from the translation file. If it doesn't exist,
/// return a formatted version of its key.

function minecraft_asset_get_name(type, name)
{
	// Digits only
	if (string_digits(name) = name)
		return name
	
	// Non-existing
	if (!text_exists(type + name))
		return (dev_mode_debug_names ? "?????? [" + name + "]" : string_format_snakecase(name))
	
	// Existing
	else
		return text_get(type + name) + (dev_mode_debug_names ? " [" + name + "]" : "")

}
