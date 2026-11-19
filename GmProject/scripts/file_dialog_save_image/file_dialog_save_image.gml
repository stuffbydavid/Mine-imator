/// @arg filename

function file_dialog_save_image(fn)
{
	return file_dialog_save(text_get("file_dialog/save/image") + " (*.png)|*.png", filename_get_valid(fn), "", text_get("file_dialog/save/image_caption"))
}
