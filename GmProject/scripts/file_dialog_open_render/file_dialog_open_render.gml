function file_dialog_open_render()
{
	return file_dialog_open(text_get("file_dialog/open/render") + " (*.mirender)|*mirender", "", "", text_get("file_dialog/open/render_caption"))
}
