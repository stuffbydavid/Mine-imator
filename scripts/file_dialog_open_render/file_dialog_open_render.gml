/// file_dialog_open_render()

function file_dialog_open_render()
{
	return file_dialog_open(text_get("filedialogopenrender") + " (*.mirender)|*mirender", "", "", text_get("filedialogopenrendercaption"))
}
