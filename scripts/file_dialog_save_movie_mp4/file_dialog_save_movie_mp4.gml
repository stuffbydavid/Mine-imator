/// file_dialog_save_movie_mp4(filename)
/// @arg filename

return file_dialog_save(text_get("filedialogsavemoviemp4") + " (*.mp4)|*.mp4", filename_valid(argument0), project_folder, text_get("filedialogsavemoviecaption"))
