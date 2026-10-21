/// @arg filename

function file_dialog_save_movie_mov(fn)
{
	return file_dialog_save(text_get("file_dialog/save/movie_mov") + " (*.mov)|*.mov", filename_get_valid(fn), project_folder, text_get("file_dialog/save/movie_caption"))
}
