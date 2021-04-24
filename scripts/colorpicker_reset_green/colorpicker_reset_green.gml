/// colorpicker_reset_green(value)
/// @arg value

function colorpicker_reset_green(value)
{
	colorpicker.green = value
	colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
}
