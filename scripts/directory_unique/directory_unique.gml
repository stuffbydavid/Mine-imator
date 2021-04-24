/// directory_unique(directory)
/// @arg directory
/// @desc If the given directory exists, add a number to it.

function directory_unique(dname)
{
	var num = 2;
	while (directory_exists_lib(dname))
		dname = argument0 + " " + string(num++)
	
	return dname
}
