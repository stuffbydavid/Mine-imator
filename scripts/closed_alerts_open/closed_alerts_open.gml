/// closed_alerts_open()
// TODO json
if (!file_exists_lib(closed_file))
	return 0

buffer_current = buffer_load_lib(closed_file)
log("Loading closed alerts", closed_file)

var am = buffer_read_byte()		   debug("am", am) debug_indent++
for (var a = 0; a < am; a++)
{
	var i = buffer_read_int();
	ds_list_add(closed_alerts, i)	 debug("i", i)
}
debug_indent--

buffer_delete(buffer_current)
