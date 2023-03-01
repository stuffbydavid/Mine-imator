/// langauge_new(fn)
/// @arg fn

function langauge_new(fn)
{
	var obj = new_obj(obj_language);
	
	with (obj)
	{
		filename = filename_name(fn)
		name = text_get("filelanguage")
		locale = text_exists("filelocale") ? string(text_get("filelocale")) : ""
	}
}
