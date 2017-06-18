/// file_dialog_open_image_pack()
/// @desc Opens a dialog box for selecting either an image or a resource pack.

return file_dialog_open(text_get("filedialogopenimageorpack") + " (*.png; *.jpg; *.zip)|*.png;*.jpg;*.jpeg;*.zip", "", "", text_get("filedialogopenimageorpackcaption"))
