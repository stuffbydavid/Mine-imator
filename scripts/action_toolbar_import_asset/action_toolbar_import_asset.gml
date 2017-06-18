/// action_toolbar_import_asset()

var fn = file_dialog_open_asset();

if (fn = "")
	return 0

asset_open(fn)
