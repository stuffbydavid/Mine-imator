/// language_remove(filename)
/// @arg filename
/// @desc Deletes language object with a matching filename

function language_remove(fn)
{
	var filename = filename_name(fn);

	with (obj_language)
	{
		if (id.filename = filename)
		{
			instance_destroy()
			break
		}
	}
}
