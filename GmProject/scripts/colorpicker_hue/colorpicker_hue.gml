/// colorpicker_saturation(value, add)
/// @arg value
/// @arg add

function colorpicker_hue(val, add)
{
	colorpicker.hue = min(255, colorpicker.hue * add + val)
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
