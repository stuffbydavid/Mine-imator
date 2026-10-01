function file_dialog_open_asset(multiple = false)
{
	if (multiple)
		return file_dialog_open_multiple(text_get("file_dialog/open/asset") + "|" + asset_exts, "", "", text_get("file_dialog/open/asset_caption"))
	else
		return file_dialog_open(text_get("file_dialog/open/asset") + "|" + asset_exts, "", "", text_get("file_dialog/open/asset_caption"))
}
