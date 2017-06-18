/// file_dialog_save_movie_png(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsavemoviepng") + " (*.png)|*.png", filename_valid(argument0), project_folder, text_get("filedialogsavemoviecaption"))
