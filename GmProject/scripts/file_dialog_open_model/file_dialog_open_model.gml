function file_dialog_open_model()
{
	return file_dialog_open(text_get("file_dialog/open/model") + " (*.mimodel;*.json;*.zip)|*.mimodel;*.json;*.zip", "", "", text_get("file_dialog/open/model_caption"))
}
