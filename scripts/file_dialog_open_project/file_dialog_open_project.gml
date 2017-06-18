/// file_dialog_open_project()

return file_dialog_open(text_get("filedialogopenproject") + " (*.mproj; *.mani; *.zip)|*.mproj;*.mani;*.zip|" + text_get("filedialogopenbackup") + " (*.mbackup*)|*.mbackup * ", "", setting_project_folder, text_get("filedialogopenprojectcaption"))
