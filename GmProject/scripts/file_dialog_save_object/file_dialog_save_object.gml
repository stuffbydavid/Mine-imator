/// file_dialog_save_object(filename)
/// @arg filename

function file_dialog_save_object(fn)
{
	return file_dialog_save(text_get("filedialogsaveobject") + " (*.miobject)|*.miobject", filename_get_valid(fn), "", text_get("filedialogsaveobjectcaption"))
}
