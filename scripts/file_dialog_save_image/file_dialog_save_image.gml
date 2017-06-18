/// file_dialog_save_image(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsaveimage") + " (*.png)|*.png", filename_valid(argument0), "", text_get("filedialogsaveimagecaption"))
