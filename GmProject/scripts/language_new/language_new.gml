/// @arg filename

function language_new(fn)
{
	with (new_obj(obj_language))
	{
		filename = filename_name(fn)
		name = text_get("file/language")
		locale = text_exists("file/locale") ? string(text_get("file/locale")) : ""
	}
}
