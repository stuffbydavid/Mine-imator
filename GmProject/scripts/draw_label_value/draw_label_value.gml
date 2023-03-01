/// draw_label_value(x, y, width, height, caption, value, [vertical])
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg caption
/// @arg value
/// @arg [vertical]

function draw_label_value(xx, yy, w, h, caption, value, vertical = false)
{
	var capwid, valuex;
	
	if (!vertical)
		caption = caption + ": "
	
	draw_set_font(font_label)
	caption = string_limit(caption, w)
	capwid = string_width(caption)
	valuex = xx + capwid
	
	if (vertical)
		draw_label(caption, xx, yy + 18, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	else
		draw_label(caption, xx, yy + h/2, fa_left, fa_middle, c_text_secondary, a_text_secondary)
	
	draw_set_font(font_value)
	
	if (vertical)
	{
		value = string_limit(value, w)
		draw_label(value, xx, yy + 36, fa_left, fa_bottom, c_text_main, a_text_main)
	}
	else
	{
		value = string_limit(value, (xx + w) - valuex)
		draw_label(value, xx + capwid, yy + h/2, fa_left, fa_middle, c_text_main, a_text_main)
	}
}
