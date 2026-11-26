function colorpicker_blue(value, add)
{
	colorpicker.blue = min(255, colorpicker.blue * add + value)
	colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
}
