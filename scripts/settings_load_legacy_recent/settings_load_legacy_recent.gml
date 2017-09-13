/// settings_load_legacy_recent(filename)
/// @arg filename

var fn = argument0;

if (!file_exists_lib(fn))
	return 0

log("Loading legacy recent files", fn)
buffer_current = buffer_load_lib(fn)

recent_amount = buffer_read_byte()
repeat (recent_amount)
{
	with (new(obj_recent))
	{
		filename = buffer_read_string_int()
		name = buffer_read_string_int()
		author = buffer_read_string_int()
		description = buffer_read_string_int()
		date = buffer_read_double()
		
		var thumbnailfn = filename_path(filename) + "thumbnail.png";
		if (file_exists_lib(thumbnailfn))
			thumbnail = texture_create(thumbnailfn)
		else
			thumbnail = null
		
		ds_list_add(app.recent_list, id)
	}
}

buffer_delete(buffer_current)