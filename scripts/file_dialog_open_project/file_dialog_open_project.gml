/// file_dialog_open_project()

return file_dialog_open(text_get("filedialogopenproject") + " (*.miproject; *.zip; *.mproj; *.mani)|*miproject;*.zip;*.mproj;*.mani|" + text_get("filedialogopenbackup") + " (*.backup*; *.mbackup*)|*.backup*;*.mbackup*", "", setting_project_folder, text_get("filedialogopenprojectcaption"))
