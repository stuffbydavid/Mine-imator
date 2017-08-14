/// text_get(key, val1, val2...)
/// @arg key
/// @arg val1
/// @arg val2...

var key, text;
key = argument[0]

if (!text_exists(key))
	return "<No text found for \"" + key + "\">"
	
text = language_map[?key]

for (var a = 1; a < argument_count; a++)
	text = string_replace(text, "%" + string(a), argument[a])

return text
