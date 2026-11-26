function colorpicker_saturation(value, add)
{
	colorpicker.saturation = min(255, colorpicker.saturation * add + value)
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
