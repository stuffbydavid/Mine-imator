/// file_dialog_open_pack()

function file_dialog_open_pack()
{
	return file_dialog_open(text_get("filedialogopenpack") + " (*.zip)|*.zip", "", "", text_get("filedialogopenpackcaption"))
}
