/// tip_set(text, x, y, width, height, [checkmouse])
/// @arg text
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [checkmouse]

var text, xx, yy, w, h, checkmouse;
var showtip;
text = argument[0]
xx = argument[1]
yy = argument[2]
w = argument[3]
h = argument[4]
checkmouse = true

if (argument_count > 5)
	checkmouse = argument[5]

if (text = "")
	return 0

if (checkmouse)
	showtip = setting_tip_show && app_mouse_box(xx, yy, w, h) && content_mouseon
else
	showtip = setting_tip_show

if (showtip)
{
	if (tip_box_x != xx || tip_box_y != yy || tip_text != text)
	{
		tip_text = text
		
		if (tip_shortcut_key != -1)
		{
			tip_shortcut_draw = true
			tip_text += "\n" + text_get("tooltipshortcut", text_control_name(tip_shortcut_key, tip_shortcut_control))
		}
		else
			tip_shortcut_draw = false
		
		var fontprev = draw_get_font();
		
		draw_set_font(font_caption)
		
		if (tip_wrap)
			tip_text_wrap = string_wrap(tip_text, 200)
		else
			tip_text_wrap = tip_text
		
		// Break tip apart based on wrap lines
		tip_text_array = string_line_array(tip_text_wrap)
		
		tip_h = 7 * (array_length_1d(tip_text_array) - 1)
		tip_h += 8 * array_length_1d(tip_text_array)
		
		// Add padding
		tip_w = string_width(tip_text_wrap) + (8 * 2)
		tip_h += (8 * 2)
		
		tip_x = 0
		tip_y = 0
		tip_x = xx + floor(tip_x - (tip_w / 2)) + (w/2)
		tip_y = yy + floor(tip_y) + h + 6
		
		tip_right = false
		
		if (tip_force_right)
		{
			tip_right = true
			tip_arrow_x = xx + w + 14
			tip_arrow_y = yy + floor(h/2)
			tip_arrow_yscale = 1
			
			tip_x = xx + w + 14
			tip_y = yy + floor(h/2 - tip_h/2)
		}
		else
		{
			tip_arrow_x = xx + (w/2)
			tip_arrow_y = tip_y
			tip_arrow_yscale = 1
		
			// Move to right
			if (tip_x < 0)
				tip_x += (tip_w/2) - 8
		
			// Move to left
			if (tip_x + tip_w > window_width)
				tip_x -= (tip_w/2) - 8
		
			// Move to top right
			if (tip_y + tip_h > window_height)
			{
				tip_y = yy - (6 + tip_h)
				tip_arrow_y = yy - 6
				tip_arrow_yscale = -1
			}
		
			// Offset away from cursor
			if (tip_arrow_yscale)
			{
				tip_y += 8
				tip_arrow_y += 8
			}
			else
			{
				tip_y -= 8
				tip_arrow_y -= 8
			}
		}
		
		tip_location_x = false
		tip_location_y = false
		tip_x = floor(tip_x)
		tip_y = floor(tip_y)
		tip_w = floor(tip_w)
		tip_h = floor(tip_h)
		
		draw_set_font(fontprev)
	}
	
	tip_show = true
	tip_box_x = xx
	tip_box_y = yy
}

tip_wrap = true