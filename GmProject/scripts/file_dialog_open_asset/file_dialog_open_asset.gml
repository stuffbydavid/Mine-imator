/// file_dialog_open_asset(multiple)
/// @arg multiple

function file_dialog_open_asset(multiple = false)
{
	if (multiple)
		return file_dialog_open_multiple(text_get("filedialogopenasset") + "|" + asset_exts, "", "", text_get("filedialogopenassetcaption"))
	else
		return file_dialog_open(text_get("filedialogopenasset") + "|" + asset_exts, "", "", text_get("filedialogopenassetcaption"))
}
