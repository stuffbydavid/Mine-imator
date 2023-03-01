/// file_dialog_open_image()
/// @desc Opens a dialog box for selecting an image.

function file_dialog_open_image()
{
	return file_dialog_open(text_get("filedialogopenimage") + " (*.png; *.jpg)|*.png;*.jpg;*.jpeg;", "", "", text_get("filedialogopenimagecaption"))
}
