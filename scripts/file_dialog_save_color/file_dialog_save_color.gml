/// file_dialog_save_color(filename)
/// @arg filename

function file_dialog_save_color(fn)
{
	return file_dialog_save(text_get("filedialogsavecolor") + " (*.micolor)|*.micolor", fn, "", text_get("filedialogsavecolorcaption"))
}
