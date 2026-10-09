function file_dialog_open_pack()
{
	return file_dialog_open(text_get("file_dialog/open/pack") + " (*.zip)|*.zip", "", "", text_get("file_dialog/open/pack_caption"))
}
