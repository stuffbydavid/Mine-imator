/// file_dialog_save_movie_mov(filename)
/// @arg filename

function file_dialog_save_movie_mov(fn)
{
	return file_dialog_save(text_get("filedialogsavemoviemov") + " (*.mov)|*.mov", filename_get_valid(fn), project_folder, text_get("filedialogsavemoviecaption"))
}
