/// filename_get_valid(filename)
/// @arg filename

function filename_get_valid(fn)
{
	fn = string_replace_all(fn, "/", "_")
	fn = string_replace_all(fn, "\\", "_")
	fn = string_replace_all(fn, ":", "_")
	fn = string_replace_all(fn, "*", "_")
	fn = string_replace_all(fn, "?", "_")
	fn = string_replace_all(fn, "\"", "_")
	fn = string_replace_all(fn, "<", "_")
	fn = string_replace_all(fn, ">", "_")
	fn = string_replace_all(fn, "|", "_")
	
	// Trim spaces
	while (string_char_at(fn, string_length(fn)) = " ")
		fn = string_copy(fn, 1, string_length(fn) - 1)
	
	return fn
}
