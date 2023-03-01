/// file_dialog_open_language()

function file_dialog_open_language()
{
	return file_dialog_open(text_get("filedialogopenlanguage") + " (*.milanguage;*.txt)|*.milanguage;*.txt", "", languages_directory, text_get("filedialogopenlanguagecaption"))
}
