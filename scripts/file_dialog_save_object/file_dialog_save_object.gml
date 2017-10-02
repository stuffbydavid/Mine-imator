/// file_dialog_save_object(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsaveobject") + " (*.miobject)|*.miobject", filename_get_valid(argument0), "", text_get("filedialogsaveobjectcaption"))
