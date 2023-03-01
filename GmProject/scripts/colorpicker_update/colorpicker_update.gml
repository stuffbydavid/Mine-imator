/// colorpicker_update(control, color, gethsb)
/// @arg control
/// @arg color
/// @arg gethsb

function colorpicker_update(control, color, gethsb)
{
	colorpicker.color = color
	
	if (gethsb)
	{
		colorpicker.hue = floor(color_get_hue(colorpicker.color))
		colorpicker.saturation = floor(color_get_saturation(colorpicker.color))
		colorpicker.brightness = floor(color_get_value(colorpicker.color))
	}
	else
	{
		colorpicker.hue = floor(min(255, colorpicker.hue))
		colorpicker.saturation = floor(min(255, colorpicker.saturation))
		colorpicker.brightness = floor(min(255, colorpicker.brightness))
	}
	
	if (control != colorpicker.tbx_red)
	{
		colorpicker.red = color_get_red(color) 
		colorpicker.tbx_red.text = string(colorpicker.red)
	}
	
	if (control != colorpicker.tbx_green)
	{
		colorpicker.green = color_get_green(color)
		colorpicker.tbx_green.text = string(colorpicker.green)
	}
	
	if (control != colorpicker.tbx_blue)
	{
		colorpicker.blue = color_get_blue(color)
		colorpicker.tbx_blue.text = string(colorpicker.blue)
	}
	
	if (control != colorpicker.tbx_hue)
		colorpicker.tbx_hue.text = string(colorpicker.hue)
	
	if (control != colorpicker.tbx_saturation)
		colorpicker.tbx_saturation.text = string(colorpicker.saturation)
	
	if (control != colorpicker.tbx_brightness)
		colorpicker.tbx_brightness.text = string(colorpicker.brightness)
	
	if (control != colorpicker.tbx_hexadecimal)
		colorpicker.tbx_hexadecimal.text = color_to_hex(colorpicker.color)
	
	script_execute(colorpicker.value_script, colorpicker.color)
}
