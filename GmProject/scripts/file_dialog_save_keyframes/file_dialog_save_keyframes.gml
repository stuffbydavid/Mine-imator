/// file_dialog_save_keyframes(filename)
/// @arg filename

function file_dialog_save_keyframes(fn)
{
	return file_dialog_save(text_get("filedialogsavekeyframes") + " (*.miframes)|*.miframes", filename_get_valid(fn), "", text_get("filedialogsavekeyframescaption"))
}
