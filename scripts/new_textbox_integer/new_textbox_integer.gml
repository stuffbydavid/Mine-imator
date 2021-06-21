/// new_textbox_integer()

function new_textbox_integer()
{
	return new_textbox(true, 64, "0123456789" + "+-/*^()")
}
