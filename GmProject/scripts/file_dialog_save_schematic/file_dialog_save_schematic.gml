/// @arg filename
/// @arg ext

function file_dialog_save_schematic(fn, ext)
{
	return file_dialog_save(text_get("file_dialog/save/schematic") + " (*" + ext + ")|*" + ext, filename_get_valid(fn), "", text_get("file_dialog/save/schematic_caption"))
}
