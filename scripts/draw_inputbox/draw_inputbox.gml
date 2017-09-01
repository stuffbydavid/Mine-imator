/// draw_inputbox(name, x, y, width, placeholder, textbox, script, [captionwidth, [height, [padding, [font]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg placeholder
/// @arg textbox
/// @arg script
/// @arg [captionwidth
/// @arg [height
/// @arg [padding
/// @arg [font]]]]

var name, xx, yy, wid, placeholder, tbx, script, capwid, h, padding, font;
name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
placeholder = argument[4]
tbx = argument[5]
script = argument[6]

if (argument_count > 7)
	capwid = argument[7]
else
	capwid = text_caption_width(name)
	
if (argument_count > 8)
	h = argument[8]
else
	h = 22
	
if (xx + wid<content_x || xx > content_x + content_width || yy + h<content_y || yy > content_y + content_height)
	return 0
	
if (argument_count > 9)
	padding = argument[9]
else
	padding = 1

if (argument_count > 10)
	font = argument[10]
else
	font = null

if (window_focus != string(tbx))
	tip_set(text_get(name + "tip"), xx, yy, wid, h)

// Label
if (capwid > 0)
{
	draw_label(text_get(name) + ":", xx, yy + floor(h / 2), fa_left, fa_middle)
	xx += capwid
	wid -= capwid
}

// Box
draw_box(xx, yy, wid, h, false, setting_color_boxes, 1)
if (window_focus = string(tbx))
	draw_box(xx, yy, wid, h, true, setting_color_highlight, 1)

// Textbox
if (font)
	draw_set_font(font)

var update = textbox_draw(tbx, xx + padding, yy + padding, wid - padding * 2, h - padding * 2);

if (tbx.text = "" && placeholder != "")
	draw_label(string_limit(placeholder, wid - padding * 2), xx + padding, yy + h / 2, fa_left, fa_middle, setting_color_boxes_text, 0.25)
if (font)
	draw_set_font(setting_font)

if (update && script)
	script_execute(script, tbx.text)

return update
