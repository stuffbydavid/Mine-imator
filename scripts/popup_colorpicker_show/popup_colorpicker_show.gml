/// popup_colorpicker_show(name, color, default, script)
/// @arg name
/// @arg color
/// @arg default
/// @arg script

var name, color, def, script;
name = argument0
color = argument1
def = argument2
script = argument3

if (popup = popup_colorpicker && popup_colorpicker.value_script = script)
	popup_close()
else
{
	popup_show(popup_colorpicker)
	popup_colorpicker.value_name = name
	popup_colorpicker.value_script = script
	
	if (text_exists(name + "caption"))
		popup_colorpicker.caption = text_get(name + "caption")
	else
		popup_colorpicker.caption = text_get(name)
	
	popup_colorpicker.def = def
	popup_colorpicker.color = color
	popup_colorpicker.red = color_get_red(color)
	popup_colorpicker.green = color_get_green(color)
	popup_colorpicker.blue = color_get_blue(color)
		
	popup_colorpicker.hue = color_get_hue(color)
	popup_colorpicker.saturation = color_get_saturation(color)
	popup_colorpicker.brightness = color_get_value(color)
	
	popup_colorpicker.tbx_red.text = string(popup_colorpicker.red)
	popup_colorpicker.tbx_green.text = string(popup_colorpicker.green)
	popup_colorpicker.tbx_blue.text = string(popup_colorpicker.blue)
	popup_colorpicker.tbx_hexadecimal.text = color_to_hex(color)
}