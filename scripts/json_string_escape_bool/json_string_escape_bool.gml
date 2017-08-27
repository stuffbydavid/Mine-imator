/// json_string_escape_bool(json)
/// @arg json

gml_pragma("forceinline")

var str = argument0;
str = string_replace_all(str, ": true", ": \"true\"")
str = string_replace_all(str, ": false", ": \"false\"")
return str