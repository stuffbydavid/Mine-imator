/// file_dialog_open_asset()

function file_dialog_open_asset()
{
	return file_dialog_open(text_get("filedialogopenasset") + "|" + asset_exts, "", "", text_get("filedialogopenassetcaption"))
}
