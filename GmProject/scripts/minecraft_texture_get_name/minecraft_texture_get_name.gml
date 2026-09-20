/// minecraft_texture_get_name(name)
/// @arg name
/// @desc Gets a translated or formatted texture key name

function minecraft_texture_get_name(name)
{
	if (name = "")
		return ""
	
	var parts, type, assetname, formatted, index;
	parts = string_split_escaped(name, "/")
	type = parts[0]
	assetname = parts[array_length(parts) - 1]
	
	if (type = "block")
	{
		assetname = string_replace(assetname, " opaque", "")
		assetname = string_replace(assetname, " nocull", "")
		assetname = string_replace(assetname, " noalpha", "")
	}
	
	if (text_exists(type + assetname))
		return minecraft_asset_get_name(type, assetname)

	formatted = string_format_snakecase(assetname)
	index = string_length(formatted)
	while (index > 0)
	{
		var c;
		c = string_char_at(formatted, index)
		if (ord(c) < ord("0") || ord(c) > ord("9"))
			break
		index--
	}
	
	if (index > 0 && index < string_length(formatted) && string_char_at(formatted, index) != " ")
		formatted = string_insert(" ", formatted, index + 1)

	return formatted
}
