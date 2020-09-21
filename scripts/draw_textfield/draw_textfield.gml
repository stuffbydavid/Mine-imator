/// draw_textfield(name, x, y, width, height, value, textbox, script, [placeholder, [labelpos, [error]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg value
/// @arg textbox
/// @arg script
/// @arg [placeholder
/// @arg [labelpos
/// @arg [error]]]

var name, xx, yy, w, h, value, textbox, script, placeholder, labelpos, err;
var update, capwidth;
name = argument[0]
xx = argument[1]
yy = argument[2]
w = argument[3]
h = argument[4]
value = argument[5]
textbox = argument[6]
script = argument[7]
placeholder = ""
labelpos = "top"
err = false

capwidth = 0

if (argument_count > 8)
	placeholder = argument[8]
	
if (argument_count > 9)
	labelpos = argument[9]

if (argument_count > 10)
	err = argument[10]

draw_set_font(font_emphasis)

if (labelpos = "top")
	yy += 48 - 28
else if (labelpos = "none")
	capwidth = 0
else
	capwidth = string_width(text_get(name)) + 10

if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	return 0

update = draw_inputbox(name, xx + capwidth, yy, w - capwidth, h, placeholder, textbox, script, false, err)

// Use microanimation from inputbox to determine color
draw_set_font(font_emphasis)

var labelcolor, labelalpha;
labelcolor = merge_color(c_text_secondary, c_accent, mcroani_arr[e_mcroani.ACTIVE])
labelalpha = lerp(a_text_secondary, 1, mcroani_arr[e_mcroani.ACTIVE])

if (err)
{
	labelcolor = c_error
	labelalpha = 1
}

draw_box_hover(xx + capwidth, yy, w - capwidth, h, max(mcroani_arr[e_mcroani.HOVER], mcroani_arr[e_mcroani.ACTIVE]))

if (labelpos = "top")
	draw_label(text_get(name), xx, yy - 8, fa_left, fa_bottom, labelcolor, labelalpha)
else if (labelpos != "none")
	draw_label(text_get(name), xx, yy + 21, fa_left, fa_bottom, labelcolor, labelalpha)

return update
