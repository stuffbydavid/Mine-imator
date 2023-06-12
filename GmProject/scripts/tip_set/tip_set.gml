/// tip_set(text, x, y, width, height, [checkmouse])
/// @arg text
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [checkmouse]

function tip_set(text, xx, yy, w, h, checkmouse = true)
{
	if (text = "")
		return 0
	
	var showtip;
	
	if (checkmouse)
		showtip = app_mouse_box(xx, yy, w, h) && content_mouseon
	else
		showtip = true
	
	if (showtip)
	{
		tip_window = window_get_current()
		
		if (tip_box_x != xx || tip_box_y != yy || tip_text != text)
		{
			tip_text = text
			
			if (tip_keybind != null)
			{
				tip_keybind_draw = true
				tip_text_keybind = text_control_name(tip_keybind)
			}
			else
			{
				tip_keybind_draw = false
				tip_text_keybind = ""
			}
			
			var fontprev = draw_get_font();
			
			draw_set_font(font_caption)
			
			if (tip_wrap)
				tip_text_wrap = string_wrap(tip_text, 200)
			else
				tip_text_wrap = tip_text
			
			// Break tip apart based on wrap lines
			tip_text_array = string_line_array(tip_text_wrap)
			
			tip_w = string_width(tip_text_wrap) + (tip_text_keybind = "" ? 0 : string_width(tip_text_keybind) + 12)
			tip_h = 7 * (array_length(tip_text_array) - 1)
			tip_h += 8 * array_length(tip_text_array)
			
			// Add padding
			tip_w += (8 * 2)
			tip_h += (8 * 2)
			
			tip_x = 0
			tip_y = 0
			tip_x = xx + floor(tip_x - (tip_w / 2)) + (w/2)
			tip_y = yy + floor(tip_y) + h + 6
			
			tip_right = false
			tip_arrow = 0
			tip_arrow_xscale = 1
			
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
				{
					tip_x += (tip_w/2)
					tip_arrow = 1
				}
				
				// Move to left
				if (tip_x + tip_w > window_width)
				{
					tip_x -= (tip_w/2)
					tip_arrow = 1
					tip_arrow_xscale = -1
					tip_arrow_x -= 1
				}
				
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
	
	if (tip_keybind != null)
		tip_keybind = null
	
	tip_wrap = true
}
