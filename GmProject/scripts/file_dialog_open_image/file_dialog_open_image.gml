/// file_dialog_open_image()
/// @desc Opens a dialog box for selecting an image.

function file_dialog_open_image()
{
	return file_dialog_open(text_get("filedialogopenimage") + " (*.png; *.jpg; *.dat)|*.png;*.jpg;*.jpeg;*.dat;", "", "", text_get("filedialogopenimagecaption"))
}
