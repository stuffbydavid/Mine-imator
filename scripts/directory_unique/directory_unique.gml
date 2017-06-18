/// directory_unique(directory)
/// @arg directory
/// @desc If the given directory exists, add a number to it.

var dname, num;
dname = argument0
num = 2
while (directory_exists_lib(dname))
	dname = argument0 + " " + string(num++)

return dname
