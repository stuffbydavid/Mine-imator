/// text_get(key, val1, val2...)
/// @arg key
/// @arg val1
/// @arg val2...

function text_get()
{
	var key, map;
	key = argument[0]
	map = language_map
	
	if (!ds_map_exists(map, key))
	{
		if (!text_exists(key))
			return "<No text found for \"" + key + "\">"
	
		map = language_english_map
	}
	
	var text = map[?key];
	for (var a = 1; a < argument_count; a++)
		text = string_replace(text, "%" + string(a), argument[a])
	
	return text
}
