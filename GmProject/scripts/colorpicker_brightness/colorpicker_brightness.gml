function colorpicker_brightness(value, add)
{
	colorpicker.brightness = min(255, colorpicker.brightness * add + value)
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}
