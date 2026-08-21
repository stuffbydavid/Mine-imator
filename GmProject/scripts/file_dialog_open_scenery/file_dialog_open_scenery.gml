/// file_dialog_open_scenery()

function file_dialog_open_scenery()
{
	return file_dialog_open(text_get("filedialogopenscenery") + " (*.schematic; *.schem; *.nbt; *.blocks)|*.schematic;*.schem;*.nbt;*.blocks", "", schematics_directory, text_get("filedialogopenscenerycaption"))
}
