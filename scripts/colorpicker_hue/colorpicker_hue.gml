/// colorpicker_saturation(value, add)
/// @arg value
/// @arg add

function colorpicker_hue(value, add)
{
	colorpicker.hue = min(255, colorpicker.hue * add + value)
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
