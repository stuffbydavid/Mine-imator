/// filename_new_ext(filename, newextension)
/// @arg filename
/// @arg newextension
/// @desc Changes the filename extension, accepting a new value with a leading dot, eg. ".png"

function filename_new_ext(fn, newext)
{
	var p;
	
	for (p = string_length(fn); p >= 0; p--)
	{
		var c = string_char_at(fn, p);
		
		if (p = 0 || c = "\\" || c = "/")
			return fn + newext
		
		if (c = ".")
			break
	}
	
	return string_copy(fn, 1, p - 1) + newext
}
