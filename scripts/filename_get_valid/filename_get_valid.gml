/// filename_get_valid(filename)
/// @arg filename

var fn = argument0;
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
