/// @desc Opens a dialog box for selecting either an image or a resource pack.

function file_dialog_open_image_pack()
{
	return file_dialog_open(text_get("file_dialog/open/image_or_pack") + " (*.png; *.jpg; *.zip)|*.png;*.jpg;*.jpeg;*.zip", "", "", text_get("file_dialog/open/image_or_pack_caption"))
}
