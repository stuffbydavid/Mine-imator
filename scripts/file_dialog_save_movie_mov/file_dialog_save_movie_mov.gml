/// file_dialog_save_movie_mov(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsavemoviemov") + " (*.mov)|*.mov", filename_get_valid(argument0), project_folder, text_get("filedialogsavemoviecaption"))
