/// colorpicker_reset_blue(value)
/// @arg value

function colorpicker_reset_blue(value)
{
	colorpicker.blue = value
	colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
}
