/// file_dialog_save_image(filename)
/// @arg filename

function file_dialog_save_image(fn)
{
	return file_dialog_save(text_get("filedialogsaveimage") + " (*.png)|*.png", filename_get_valid(fn), "", text_get("filedialogsaveimagecaption"))
}
