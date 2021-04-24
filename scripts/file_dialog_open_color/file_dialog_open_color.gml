/// file_dialog_open_color()

function file_dialog_open_color()
{
	return file_dialog_open(text_get("filedialogopencolor") + " (*.micolor; *.mcolor)|*.micolor;*.mcolor", "", "", text_get("filedialogopencolorcaption"))
}
