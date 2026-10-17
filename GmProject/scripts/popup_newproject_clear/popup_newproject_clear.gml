function popup_newproject_clear()
{
	popup_newproject.tbx_name.text = text_get("new_project/name_default")
	popup_newproject.folder = filename_get_valid(popup_newproject.tbx_name.text)
	popup_newproject.description = ""
}
