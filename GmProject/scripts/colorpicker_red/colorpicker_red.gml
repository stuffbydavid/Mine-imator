/// colorpicker_red(value, add)
/// @arg value
/// @arg add

function colorpicker_red(val, add)
{
	colorpicker.red = min(255, colorpicker.red * add + val)
	colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
}
