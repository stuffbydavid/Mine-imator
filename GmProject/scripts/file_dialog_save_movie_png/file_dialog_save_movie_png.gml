/// @arg filename

function file_dialog_save_movie_png(fn)
{
	return file_dialog_save(text_get("file_dialog/save/movie_png") + " (*.png)|*.png", filename_get_valid(fn), project_folder, text_get("file_dialog/save/movie_caption"))
}
