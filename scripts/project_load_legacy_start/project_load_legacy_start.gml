/// project_load_legacy_start(filename)
/// @arg filename
/// @desc Starts loading a legacy (pre 1.1.0) file.

var fn = argument0;

buffer_current = buffer_load_lib(fn)
load_format = buffer_read_byte()

// Check format too new
if (load_format > e_project.FORMAT_CB_103) 
{
	log("Invalid format", load_format)
	error("erroropenprojectnewer")
	buffer_delete(buffer_current)
	return false
}

// Check format too old
else if (load_format < e_project.FORMAT_05)
{
	log("Too old legacy project, format", load_format)
	error("errorfilecorrupted")
	buffer_delete(buffer_current)
	return false
}

return true