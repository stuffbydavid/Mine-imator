/// file_dialog_save_movie_png(filename)
/// @arg filename

function file_dialog_save_movie_png(fn)
{
	return file_dialog_save(text_get("filedialogsavemoviepng") + " (*.png)|*.png", filename_get_valid(fn), project_folder, text_get("filedialogsavemoviecaption"))
}
