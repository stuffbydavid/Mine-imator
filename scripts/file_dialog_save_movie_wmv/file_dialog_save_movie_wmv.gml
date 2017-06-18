/// file_dialog_save_movie_wmv(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsavemoviewmv") + " (*.wmv)|*.wmv", filename_valid(argument0), project_folder, text_get("filedialogsavemoviecaption"))
