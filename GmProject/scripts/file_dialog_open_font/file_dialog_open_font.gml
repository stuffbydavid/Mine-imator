function file_dialog_open_font()
{
	return file_dialog_open(text_get("file_dialog/open/font") + " (*.ttf)|*.ttf", "", "", text_get("file_dialog/open/font_caption"))
}
