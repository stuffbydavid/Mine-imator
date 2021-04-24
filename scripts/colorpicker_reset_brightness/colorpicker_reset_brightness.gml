/// colorpicker_reset_brightness(value)
/// @arg value

function colorpicker_reset_brightness(value)
{
	colorpicker.brightness = value
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
