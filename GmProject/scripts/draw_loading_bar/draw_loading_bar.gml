/// draw_loading_bar(x, y, width, height, percent, text, hinttext)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg percent
/// @arg text
/// @arg hinttext

function draw_loading_bar(xx, yy, wid, hei, perc, text, hinttext = "")
{
	yy += 8
	draw_label(text, xx, yy, fa_left, fa_center, c_text_main, a_text_main, font_value)
	
	draw_label(hinttext, xx + wid, yy, fa_right, fa_center, c_text_secondary, a_text_secondary, font_value)
	yy += 16
	
	draw_box(xx, yy, wid, hei, false, c_border, a_border)
	draw_box(xx, yy, wid * perc, hei, false, c_accent, 1)
}
