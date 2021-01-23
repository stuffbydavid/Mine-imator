/// popup_newproject_clear()

popup_newproject.tbx_name.text = text_get("newprojectnamedefault")
popup_newproject.folder = filename_get_valid(popup_newproject.tbx_name.text)
