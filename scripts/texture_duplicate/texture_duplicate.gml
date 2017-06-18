/// texture_duplicate(texture)
/// @arg texture

var tex, fn;
tex = argument0
fn = file_directory + "tmp.png"

texture_export(tex, fn)
return texture_create(fn)
