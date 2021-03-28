/// draw_loading_bar(x, y, width, height, percent, text)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg percent
/// @arg text

var xx, yy, wid, hei, perc, text;
xx = argument0
yy = argument1
wid = argument2
hei = argument3
perc = argument4
text = argument5

yy += 8
draw_label(text_get("loadingstagedone", string(floor(perc * 100)), text), xx, yy, fa_left, fa_center, c_text_main, a_text_main, font_value)
yy += 16

draw_box(xx, yy, wid, hei, false, c_border, a_border)
draw_box(xx, yy, wid * perc, hei, false, c_accent, 1)
