/// file_dialog_open_scenery()

return file_dialog_open(text_get("filedialogopenscenery") + " (*.schematic; *.blocks)|*.schematic;*.blocks", "", schematics_directory, text_get("filedialogopenscenerycaption"))
