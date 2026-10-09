/// @arg filename

function file_dialog_save_movie_wmv(fn)
{
	return file_dialog_save(text_get("file_dialog/save/movie_wmv") + " (*.wmv)|*.wmv", filename_get_valid(fn), project_folder, text_get("file_dialog/save/movie_caption"))
}
