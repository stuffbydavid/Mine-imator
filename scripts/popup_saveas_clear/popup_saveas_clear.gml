/// popup_saveas_clear()

function popup_saveas_clear()
{
	popup_saveas.tbx_name.text = text_get("saveascopy", project_name)
	popup_saveas.folder = text_get("saveascopy", filename_name(project_folder))
	popup_saveas.description = ""
}
