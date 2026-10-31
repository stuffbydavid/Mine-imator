/// @arg filename

function file_dialog_save_keyframes(fn)
{
	return file_dialog_save(text_get("file_dialog/save/keyframes") + " (*.miframes)|*.miframes", filename_get_valid(fn), "", text_get("file_dialog/save/keyframes_caption"))
}
