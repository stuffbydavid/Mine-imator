/// popup_colorpicker_update(control, color, gethsb)
/// @arg control
/// @arg color
/// @arg gethsb

var control, color, gethsb;
control = argument0
color = argument1
gethsb = argument2

popup_colorpicker.color = color

if (gethsb)
{
	if (popup_colorpicker.hsb_mode)
	{
		popup_colorpicker.hue = color_get_red(popup_colorpicker.color)
		popup_colorpicker.saturation = color_get_green(popup_colorpicker.color)
		popup_colorpicker.brightness = color_get_blue(popup_colorpicker.color)
	}
	else
	{
		popup_colorpicker.hue = color_get_hue(popup_colorpicker.color)
		popup_colorpicker.saturation = color_get_saturation(popup_colorpicker.color)
		popup_colorpicker.brightness = color_get_value(popup_colorpicker.color)
	}
}
else
{
	if (popup_colorpicker.hsb_mode)
		popup_colorpicker.color = popup_colorpicker.hue + popup_colorpicker.saturation * 256 + popup_colorpicker.brightness * 256 * 256
		
	popup_colorpicker.hue = min(255, popup_colorpicker.hue)
	popup_colorpicker.saturation = min(255, popup_colorpicker.saturation)
	popup_colorpicker.brightness = min(255, popup_colorpicker.brightness)
}

if (control != popup_colorpicker.tbx_red)
{
	popup_colorpicker.red = color_get_red(color) 
	popup_colorpicker.tbx_red.text = string(popup_colorpicker.red)
}

if (control != popup_colorpicker.tbx_green)
{
	popup_colorpicker.green = color_get_green(color)
	popup_colorpicker.tbx_green.text = string(popup_colorpicker.green)
}

if (control != popup_colorpicker.tbx_blue)
{
	popup_colorpicker.blue = color_get_blue(color)
	popup_colorpicker.tbx_blue.text = string(popup_colorpicker.blue)
}

if (control != popup_colorpicker.tbx_hue)
	popup_colorpicker.tbx_hue.text = string(popup_colorpicker.hue)
	
if (control != popup_colorpicker.tbx_saturation)
	popup_colorpicker.tbx_saturation.text = string(popup_colorpicker.saturation)
	
if (control != popup_colorpicker.tbx_brightness)
	popup_colorpicker.tbx_brightness.text = string(popup_colorpicker.brightness)
	
if (control != popup_colorpicker.tbx_hexadecimal)
	popup_colorpicker.tbx_hexadecimal.text = color_to_hex(popup_colorpicker.color)
	
script_execute(popup_colorpicker.value_script, popup_colorpicker.color)
