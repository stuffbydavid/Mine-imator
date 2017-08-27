/// recent_save()
// TODO Json
/*
return 0
buffer_current = buffer_create(8, buffer_grow, 1)
debug("Saving recent", recent_file)

buffer_write_byte(recent_amount)
for (var r = 0; r < recent_amount; r++)
{
	buffer_write_string_int(recent_filename[r])
	buffer_write_string_int(recent_name[r])
	buffer_write_string_int(recent_author[r])
	buffer_write_string_int(recent_description[r])
	buffer_write_double(recent_date[r])
}

buffer_save_lib(buffer_current, recent_file)
buffer_delete(buffer_current)
*/