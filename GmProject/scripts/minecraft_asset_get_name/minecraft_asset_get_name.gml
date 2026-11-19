/// @desc Gets a name from the translation file. If it doesn't exist,
/// return a formatted version of its key.

function minecraft_asset_get_name(type, name)
{
	// Digits only
	if (string_digits(name) = name)
		return name
	
	var key, text, translated;
	key = type + "/" + name
	text = language_english_map[?key]

	// Non-existing
	if (is_undefined(text))
		return (debug_names ? "?????? [" + name + "]" : string_format_snakecase(name))
	
	translated = language_map[?key]
	if (!is_undefined(translated))
		text = translated

	return text + (debug_names ? " [" + name + "]" : "")
}
