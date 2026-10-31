/// @arg filename

function file_dialog_save_movie_mp4(fn)
{
	return file_dialog_save(text_get("file_dialog/save/movie_mp4") + " (*.mp4)|*.mp4", filename_get_valid(fn), project_folder, text_get("file_dialog/save/movie_caption"))
}
