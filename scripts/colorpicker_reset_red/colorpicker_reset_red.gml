/// colorpicker_reset_red(value)
/// @arg value

function colorpicker_reset_red(value)
{
	colorpicker.red = value
	colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
}
