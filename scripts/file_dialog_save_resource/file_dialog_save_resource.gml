/// file_dialog_save_resource(filename, extensions)
/// @arg filename
/// @arg extensions

function file_dialog_save_resource(fn, exts)
{
	return file_dialog_save(" * " + exts + "|*" + exts, filename_get_valid(fn), "", text_get("filedialogsaveresourcecaption"))
}
