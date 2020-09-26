/// draw_textfield_num(name, x, y, width, value, multiplier, min, max, default, snap, textbox, script, [disabled, [right_side]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg value
/// @arg multiplier
/// @arg min
/// @arg max
/// @arg default
/// @arg snap
/// @arg textbox
/// @arg script
/// @arg [disabled
/// @arg [right_side]]

var name, xx, yy, wid, value, mul, minval, maxval, def, snapval, tbx, script, disabled, right_side;
var capwidth, hei, fieldx;
name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
value = argument[4]
mul = argument[5]
minval = argument[6]
maxval = argument[7]
def = argument[8]
snapval = argument[9]
tbx = argument[10]
script = argument[11]
disabled = false
right_side = false

if (argument_count > 12)
	disabled = argument[12]

if (argument_count > 13)
	right_side = argument[13]

draw_set_font(font_emphasis)

hei = 28
capwidth = string_width(text_get(name)) + 10

if (xx + wid + capwidth < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	return 0

//if (!disabled)
//	context_menu_area(xx, yy, wid + capwidth, hei, "contextmenuvalue", value, e_value_type.NUMBER, script, def)

if (right_side)
	fieldx = dx + dw - wid
else
	fieldx = xx + capwidth

if (draw_inputbox(name, fieldx, yy, wid, 28, string(def), tbx, null, disabled))
	script_execute(script, clamp(string_get_real(tbx.text, def), minval, maxval), false)

// Use microanimation from inputbox to determine color
var labelcolor, labelalpha;
labelcolor = merge_color(c_text_secondary, c_accent, mcroani_arr[e_mcroani.ACTIVE])
labelcolor = merge_color(labelcolor, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

labelalpha = lerp(a_text_secondary, 1, mcroani_arr[e_mcroani.ACTIVE])
labelalpha = lerp(labelalpha, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])

draw_box_hover(fieldx, yy, wid, hei, max(mcroani_arr[e_mcroani.HOVER], mcroani_arr[e_mcroani.ACTIVE]) * (1 - mcroani_arr[e_mcroani.DISABLED]))

draw_label(text_get(name), xx, yy + 21, fa_left, fa_bottom, labelcolor, labelalpha, font_emphasis)

// Drag
if (app_mouse_box(xx, yy, capwidth, hei) && content_mouseon && window_focus != string(tbx) && !disabled)
{
	mouse_cursor = cr_size_we
	
	if (mouse_left_pressed)
		window_busy = name + "press"
}

// Textbox press
if (app_mouse_box(fieldx, yy, wid, hei) && content_mouseon && window_focus != string(tbx) && !disabled)
{
	if (mouse_left_pressed)
	{
		tbx.text = string_decimals(value)
		window_focus = string(tbx)
		window_busy = ""
	}
}

// Mouse pressed
if (window_busy = name + "press")
{
	mouse_cursor = cr_size_we
	
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
	else if (mouse_dx != 0)
	{
		dragger_drag_value = value
		window_busy = name + "drag" // Start dragging
	}
}

// Is dragging
if (window_busy = name + "drag")
{ 
	mouse_cursor = cr_none
	dragger_drag_value += (mouse_x - mouse_click_x) * mul * dragger_multiplier
	window_mouse_set(mouse_click_x, mouse_click_y)
	
	var d = clamp(snap(dragger_drag_value, snapval), minval, maxval) - value;
	if (d <> 0)
	{
		script_execute(script, d, true)
		tbx.text = string_decimals(value + d)
	}
	
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

// Idle
if (window_busy != name + "drag" && window_busy != name + "press" && window_focus != string(tbx))
	tbx.text = string_decimals(value)
