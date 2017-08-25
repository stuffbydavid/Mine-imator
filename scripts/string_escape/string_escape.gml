/// string_escape(string)
/// @arg string

var str = argument0;

str = string_replace_all(str, "\n", "\\n")
str = string_replace_all(str, "\t", "\\t")
str = string_replace_all(str, "\"", "\\\"")

return str