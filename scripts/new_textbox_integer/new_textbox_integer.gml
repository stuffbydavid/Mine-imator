/// new_textbox_integer()

function new_textbox_integer()
{
	if (app.setting_unlimited_values)
		return new_textbox_ninteger()
	
	return new_textbox(true, 64, "0123456789" + "+-/*^()")
}
