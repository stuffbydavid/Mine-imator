/// colorpicker_startup()

function colorpicker_startup()
{
	colorpicker = new_obj(obj_colorpicker)
	
	with (colorpicker)
	{
		value_name = ""
		value_script = null
		color = null
		def = null
		hue = 0
		saturation = 0
		value = 0
		tbx_red = new_textbox(1, 3, "0123456789")
		tbx_green = new_textbox(1, 3, "0123456789")
		tbx_blue = new_textbox(1, 3, "0123456789")
		tbx_hue = new_textbox(1, 3, "0123456789")
		tbx_saturation = new_textbox(1, 3, "0123456789")
		tbx_brightness = new_textbox(1, 3, "0123456789")
		tbx_hexadecimal = new_textbox_hex()
		tbx_red.next_tbx = tbx_green
		tbx_green.next_tbx = tbx_blue
		tbx_blue.next_tbx = tbx_hexadecimal
		tbx_hexadecimal.next_tbx = tbx_red
		mode = "rgb"
	}
}
