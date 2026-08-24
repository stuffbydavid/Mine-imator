/// colorpicker_green(value, add)
/// @arg value
/// @arg add

function colorpicker_green(val, add)
{
	colorpicker.green = min(255, colorpicker.green * add + val)
	colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
}
