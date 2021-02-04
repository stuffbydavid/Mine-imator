/// colorpicker_reset_saturation(value)
/// @arg value

colorpicker.saturation = argument0
colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
