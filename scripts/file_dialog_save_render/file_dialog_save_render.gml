/// file_dialog_save_render(filename)
/// @arg filename

function file_dialog_save_render(fn)
{
	return file_dialog_save(text_get("filedialogsaverender") + " (*.mirender)|*.mirender", filename_get_valid(fn), render_directory, text_get("filedialogsaverendercaption"))
}
