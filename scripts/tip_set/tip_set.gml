/// tip_set(text, x, y, width, height)
/// @arg text
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var text, xx, yy, w, h;
text = argument0
xx = argument1
yy = argument2
w = argument3
h = argument4

if (text = "")
    return 0

if (tip_shortcut_key)
{
    text += "\n (" + text_control_name(tip_shortcut_key, tip_shortcut_control) + ": " + text_get("tipshortcut") + ")"
    tip_shortcut_key = null
}

if (setting_tip_show && app_mouse_box(xx, yy, w, h) && content_mouseon &&
	(mouse_still > fps * setting_tip_delay || (tip_box_x = xx && tip_box_y = yy)))
{
    if (tip_box_x != xx || tip_box_y != yy || tip_text != text)
	{
        tip_text = text
        
        if (tip_wrap)
			tip_text_wrap = string_wrap(tip_text, tip_maxwid - tip_padding * 2)
        else
			tip_text_wrap = tip_text
			
        tip_w = string_width(tip_text_wrap) + tip_padding * 2
        tip_h = string_height(tip_text_wrap) + tip_padding * 2
        
        if (xx + w / 2 + tip_w < window_width) // To right
		{ 
            tip_x = xx + w / 2
            tip_location_x = true
        }
		else // To left
		{
            tip_x = xx + w / 2 - tip_w
            tip_location_x = false
        }
        
        if (yy > 50) // Above
		{
            tip_y = yy - tip_h - 12
            tip_location_y = true
        }
		else // Below
		{
            tip_y = yy + h+12
            tip_location_y = false
        }
        
        tip_x = floor(tip_x)
        tip_y = floor(tip_y)
        tip_w = floor(tip_w)
        tip_h = floor(tip_h)
    }
    
    tip_show = true
    tip_box_x = xx
    tip_box_y = yy
}

tip_wrap = true
