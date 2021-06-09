/// new_textbox_decimals()

function new_textbox_decimals()
{
	if (app.setting_unlimited_values)
		return new_textbox_ndecimals()
	
	return new_textbox(true, 64, ".0123456789" + "+-/*^()")
}
