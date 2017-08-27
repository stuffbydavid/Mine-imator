/// file_dialog_save_resource(filename, extensions)
/// @arg filename
/// @arg extensions

return file_dialog_save(" * "+argument1 + "|*" + argument1, filename_get_valid(argument0), "", text_get("filedialogsaveresourcecaption"))
