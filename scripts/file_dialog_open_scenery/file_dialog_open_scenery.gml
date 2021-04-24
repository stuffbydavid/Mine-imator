/// file_dialog_open_scenery()

function file_dialog_open_scenery()
{
	return file_dialog_open(text_get("filedialogopenscenery") + " (*.schematic; *.nbt; *.blocks)|*.schematic;*.nbt;*.blocks", "", schematics_directory, text_get("filedialogopenscenerycaption"))
}
