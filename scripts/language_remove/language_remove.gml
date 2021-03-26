/// language_remove(filename)
/// @arg filename
/// @desc Deletes language object with a matching filename

var fn = filename_name(argument0);

with (obj_language)
{
	if (filename = fn)
	{
		instance_destroy()
		break
	}
}
