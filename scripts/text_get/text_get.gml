/// text_get(name, val1, val2...)
/// @arg name
/// @arg val1
/// @arg val2...

var name, text;
name = argument[0]

if (!text_exists(name))
	return "<No text found for \"" + name + "\">"
	
text = ds_map_find_value(language_map, name)

for (var a = 1; a < argument_count; a++)
	text = string_replace(text, "%" + string(a), argument[a])

return text
