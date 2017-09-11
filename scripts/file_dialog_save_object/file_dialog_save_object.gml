/// file_dialog_save_object(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsaveobject") + " (*.miobj)|*.miobj", filename_get_valid(argument0), "", text_get("filedialogsaveobjectcaption"))
