/// @arg filename

function language_new(fn)
{
	with (new_obj(obj_language))
	{
		filename = filename_name(fn)
		name = text_get("filelanguage")
		locale = text_exists("filelocale") ? string(text_get("filelocale")) : ""
	}
}
