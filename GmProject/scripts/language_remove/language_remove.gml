/// @desc Deletes the language object with a matching filename.
/// @arg filename

function language_remove(fn)
{
	var filename = filename_name(fn);

	with (obj_language)
	{
		if (self.filename = filename)
		{
			instance_destroy()
			break
		}
	}
}
