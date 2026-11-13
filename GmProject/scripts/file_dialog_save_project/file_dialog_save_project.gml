/// @arg filename

function file_dialog_save_project(fn)
{
	return file_dialog_save("", fn, setting_project_folder, text_get("file_dialog/save/project_caption"))
}
