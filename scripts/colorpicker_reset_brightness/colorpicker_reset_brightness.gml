/// colorpicker_reset_brightness(value)
/// @arg value

colorpicker.brightness = argument0
colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
