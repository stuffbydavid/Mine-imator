/// colorpicker_saturation(value, add)
/// @arg value
/// @arg add

function colorpicker_saturation(val, add)
{
	colorpicker.saturation = min(255, colorpicker.saturation * add + val)
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
