/// @arg filename

function file_dialog_save_object(fn)
{
	return file_dialog_save(text_get("file_dialog/save/object") + " (*.miobject)|*.miobject", filename_get_valid(fn), "", text_get("file_dialog/save/object_caption"))
}
