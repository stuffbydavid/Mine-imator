/// text_max_width(name1, name2, name3...)
/// @arg name1
/// @arg name2
/// @arg name3...

var wid = 0;
for (var a = 0; a < argument_count; a++)
	wid = max(wid, string_width(text_get(argument[a]) + ":"))

return wid
