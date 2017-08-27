/// recent_open()
// TODO json
/*
if (!file_exists_lib(recent_file))
	return 0

buffer_current = buffer_load_lib(recent_file)
log("Loading recent", recent_file)

recent_amount = buffer_read_byte()						debug("recent_amount", recent_amount) debug_indent++
for (var r = 0; r < recent_amount; r++)
{
	var thumbnailfn;
	recent_filename[r] = buffer_read_string_int()		 debug("recent_filename", recent_filename[r])
	recent_name[r] = buffer_read_string_int()			 debug("recent_name", recent_name[r])
	recent_author[r] = buffer_read_string_int()		   debug("recent_author", recent_author[r])
	recent_description[r] = buffer_read_string_int()	  debug("recent_description", recent_description[r])
	recent_date[r] = buffer_read_double()				 debug("recent_date", recent_date[r])
	
	thumbnailfn = filename_path(recent_filename[r]) + "thumbnail.png"
	if (file_exists_lib(thumbnailfn))
		recent_thumbnail[r] = texture_create(thumbnailfn)
	else
		recent_thumbnail[r] = null
}
debug_indent--


buffer_delete(buffer_current)
*/