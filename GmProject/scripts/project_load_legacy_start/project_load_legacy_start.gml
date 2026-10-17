/// @desc Starts loading a legacy (pre 1.1.0) file.
/// @arg filename

function project_load_legacy_start(fn)
{
	buffer_current = buffer_load_lib(fn)
	load_format = buffer_read_byte()
	
	// Check format too new
	if (load_format > e_project.FORMAT_CB_103) 
	{
		log("Invalid format", load_format)
		error("error/file_corrupted")
		buffer_delete(buffer_current)
		return false
	}
	
	// Check format too old
	else if (load_format < e_project.FORMAT_05)
	{
		log("Too old legacy project, format", load_format)
		error("error/file_corrupted")
		buffer_delete(buffer_current)
		return false
	}
	
	log("load_format", load_format)
	
	return true
}
