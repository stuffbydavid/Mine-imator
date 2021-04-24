/// filename_get_valid(filename)
/// @arg filename

function filename_get_valid(fn)
{
	fn = string_replace_all(fn, " / ", "")
	fn = string_replace_all(fn, "\\", "")
	fn = string_replace_all(fn, ":", "")
	fn = string_replace_all(fn, " * ", "")
	fn = string_replace_all(fn, "?", "")
	fn = string_replace_all(fn, "\"", "")
	fn = string_replace_all(fn, " < ", "")
	fn = string_replace_all(fn, " > ", "")
	fn = string_replace_all(fn, "|", "")
	
	return fn
}
