function popup_saveas_clear()
{
	popup_saveas.tbx_name.text = text_get("save_as/copy", project_name)
	popup_saveas.folder = text_get("save_as/copy", filename_name(project_folder))
	popup_saveas.description = ""
}
