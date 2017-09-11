/// file_dialog_save_color(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsavecolor") + " (*.micolor)|*.micolor", argument0, "", text_get("filedialogsavecolorcaption"))
