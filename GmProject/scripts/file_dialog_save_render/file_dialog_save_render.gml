/// @arg filename

function file_dialog_save_render(fn)
{
	return file_dialog_save(text_get("file_dialog/save/render") + " (*.mirender)|*.mirender", filename_get_valid(fn), render_directory, text_get("file_dialog/save/render_caption"))
}
