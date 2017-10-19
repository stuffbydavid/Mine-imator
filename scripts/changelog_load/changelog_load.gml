/// changelog_load(fn, [list])
/// @arg fn
/// @arg [list]

var fn, list;
fn = argument[0]
list = content_list

if(argument_count > 1)
	list = argument[1]

if(fn = "")
	return false

var file, line;
file = file_text_open_read(fn)
line = "";

ds_list_clear(list)

while (!file_text_eof(file))
{
	line = file_text_readln(file)
	
	line = string_replace(line, "\n", "")
	line = string_replace(line, "\r", "")
	
	ds_list_add(list, line)
	
	if(dev_mode)
		log("Changelog: Added '" + line + "'")
	
}
file_text_close(file)

return true
