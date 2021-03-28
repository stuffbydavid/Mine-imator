/// draw_label_value(x, y, width, height, caption, value)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg caption
/// @arg value

var xx, yy, w, h, caption, value, capwid, valuex;
xx = argument0
yy = argument1
w = argument2
h = argument3
caption = argument4 + ": "
value = argument5

draw_set_font(font_label)
caption = string_limit(caption, w)
capwid = string_width(caption)
valuex = xx + capwid

draw_label(caption, xx, yy + h/2, fa_left, fa_middle, c_text_secondary, a_text_secondary)


draw_set_font(font_value)
value = string_limit(value, (xx + w) - valuex)

draw_label(value, xx + capwid, yy + h/2, fa_left, fa_middle, c_text_main, a_text_main)
