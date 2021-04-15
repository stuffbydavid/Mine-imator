/// colorpicker_reset_hue(value)
/// @arg value

colorpicker.hue = argument0
colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
