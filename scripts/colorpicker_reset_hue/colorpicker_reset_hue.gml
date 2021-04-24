/// colorpicker_reset_hue(value)
/// @arg value

function colorpicker_reset_hue(value)
{
	colorpicker.hue = value
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
