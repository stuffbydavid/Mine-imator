/// string_remove_newline(string)
/// @arg string

function string_remove_newline(str)
{
	return string_replace_all(str, "\n", " ")
}
