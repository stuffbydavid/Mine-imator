/// popup_saveas_clear()

function popup_saveas_clear()
{
	popup_saveas.tbx_name.text = project_name + " copy"
	popup_saveas.folder = filename_name(project_folder) + " copy"
}
