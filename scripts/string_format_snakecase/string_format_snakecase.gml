/// string_format_snakecase(string)
/// @arg string

return string_replace_all(string_upper(string_char_at(argument0,1)) + string_delete(argument0, 1, 1), "_", " ")