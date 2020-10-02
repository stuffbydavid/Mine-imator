/// draw_button_color(name, x, y, width, color, default, hsbmode, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg color
/// @arg default
/// @arg hsbmode
/// @arg script
/// @desc Draws a button that opens the color dialog.

var name, xx, yy, wid, color, def, hsbmode, script;
name = argument0
xx = argument1
yy = argument2
wid = argument3
color = argument4
def = argument5
hsbmode = argument6
script = argument7

if (draw_button_normal(name, xx, yy, wid, 32, e_button.TEXT, popup = popup_colorpicker && popup_colorpicker.value_name = name, true, true, icons.COLOR, hsbmode ? rgb_to_hsb(color) : color))
{
	popup_colorpicker_show(name, color, def, script)
	
	/*
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
		popup_colorpicker.hsb_mode = hsbmode
		
		if (hsbmode)
		{
			popup_colorpicker.hue = popup_colorpicker.red
			popup_colorpicker.saturation = popup_colorpicker.green
			popup_colorpicker.brightness = popup_colorpicker.blue
		}
		else
		{
			popup_colorpicker.hue = color_get_hue(color)
			popup_colorpicker.saturation = color_get_saturation(color)
			popup_colorpicker.brightness = color_get_value(color)
		}
		popup_colorpicker.tbx_red.text = string(popup_colorpicker.red)
		popup_colorpicker.tbx_green.text = string(popup_colorpicker.green)
		popup_colorpicker.tbx_blue.text = string(popup_colorpicker.blue)
		popup_colorpicker.tbx_hue.text = string(popup_colorpicker.hue)
		popup_colorpicker.tbx_saturation.text = string(popup_colorpicker.saturation)
		popup_colorpicker.tbx_brightness.text = string(popup_colorpicker.brightness)
		popup_colorpicker.tbx_hexadecimal.text = color_to_hex(color)
	}
	*/
}
