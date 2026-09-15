/// colorpicker_blue(value, add)
/// @arg value
/// @arg add

function colorpicker_blue(val, add)
{
	colorpicker.blue = min(255, colorpicker.blue * add + val)
	colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
}
