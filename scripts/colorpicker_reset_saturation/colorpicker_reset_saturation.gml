/// colorpicker_reset_saturation(value)
/// @arg value

function colorpicker_reset_saturation(value)
{
	colorpicker.saturation = value
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
