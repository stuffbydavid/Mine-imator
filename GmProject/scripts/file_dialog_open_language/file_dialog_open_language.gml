function file_dialog_open_language()
{
	return file_dialog_open(text_get("file_dialog/open/language") + " (*.milanguage;*.txt)|*.milanguage;*.txt", "", languages_directory, text_get("file_dialog/open/language_caption"))
}
