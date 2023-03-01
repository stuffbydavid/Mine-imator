/// file_dialog_open_font()

function file_dialog_open_font()
{
	return file_dialog_open(text_get("filedialogopenfont") + " (*.ttf)|*.ttf", "", "", text_get("filedialogopenfontcaption"))
}
