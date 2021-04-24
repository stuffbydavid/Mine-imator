/// string_format_snakecase(string)
/// @arg string

function string_format_snakecase(str)
{
	return string_replace_all(string_upper(string_char_at(str, 1)) + string_delete(str, 1, 1), "_", " ")
}
