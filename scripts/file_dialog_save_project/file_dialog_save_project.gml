/// file_dialog_save_project(filename)
/// @arg filename

function file_dialog_save_project(fn)
{
	return file_dialog_save("", fn, setting_project_folder, text_get("filedialogsaveprojectcaption"))
}
