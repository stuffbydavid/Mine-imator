function file_dialog_open_project()
{
	return file_dialog_open(text_get("file_dialog/open/project") + " (*.miproject; *.zip; *.mproj; *.mani)|*miproject;*.zip;*.mproj;*.mani|" + text_get("file_dialog/open/backup") + " (*.backup*; *.mbackup*)|*.backup*;*.mbackup*", "", setting_project_folder, text_get("file_dialog/open/project_caption"))
}
