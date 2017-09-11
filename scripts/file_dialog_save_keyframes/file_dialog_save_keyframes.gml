/// file_dialog_save_keyframes(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsavekeyframes") + " (*.miframes)|*.miframes", filename_get_valid(argument0), "", text_get("filedialogsavekeyframescaption"))
