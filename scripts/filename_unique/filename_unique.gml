/// filename_unique(filename)
/// @arg filename
/// @desc If the given filename exists, add a number to it.

var fn, num;
fn = argument0
num = 2
while (file_exists_lib(fn))
    fn = filename_new_ext(argument0, "") + " " + string(num++) + filename_ext(argument0)

return fn
