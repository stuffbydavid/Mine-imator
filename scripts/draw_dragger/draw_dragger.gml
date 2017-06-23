/// draw_dragger(name, x, y, width, value, multiplier, min, max, default, snap, textbox, script, [captionwidth, [tip]])
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
/// @arg [captionwidth
/// @arg [tip]]

var name, xx, yy, wid, value, mul, minval, maxval, def, snapval, tbx, script, capwid, tip;
var hei, text;
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

if (argument_count > 12)
	capwid = argument[12]
else
	capwid = text_caption_width(name)
	
if (argument_count > 13)
	tip = argument[13]
else 
	tip = text_get(name + "tip")
	
tip += "\n" + text_get("draggertip")

hei = 18 
text = text_get(name)

if (text != "")
	draw_label(text + ":", xx, yy + hei / 2, fa_left, fa_middle)

if (window_focus != string(tbx))
	tip_set(tip, xx, yy, capwid + string_width(string(value) + tbx.suffix) + 32, hei)
	
if (app_mouse_box(xx + capwid, yy, wid - capwid, hei) && content_mouseon && window_focus != string(tbx))
{
	mouse_cursor = cr_size_we
	
	if (mouse_left_pressed)
	{
		window_focus = name
		window_busy = name + "press"
	}
	
	// Reset to 0
	if (mouse_right_pressed && def != no_limit)
	{
		window_focus = name
		script_execute(script, clamp(snap(def, snapval), minval, maxval), 0)
	}
}

// Mouse pressed
if (window_busy = name + "press")
{ 
	mouse_cursor = cr_size_we
	
	if (!mouse_left) // Type
	{
		tbx.text = string_decimals(value)
		window_focus = string(tbx)
		window_busy = ""
	}
	
	if (mouse_dx != 0)
	{
		dragger_drag_value = value
		window_busy = name + "drag" // Start dragging
	}
}

// Is dragging
if (window_busy = name + "drag")
{ 
	mouse_cursor = cr_size_we
	dragger_drag_value += mouse_dx * mul

	var d = clamp(snap(dragger_drag_value, snapval), minval, maxval) - value;
	if (d <> 0)
		script_execute(script, d, true)
	
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

// Mouse wheel
if (window_busy = "" && window_focus = name && mouse_wheel != 0)
{
	var newval;
	if (snapval = 0)
		newval = clamp(value - mouse_wheel * mul, minval, maxval)
	else
		newval = clamp(value - mouse_wheel * snapval, minval, maxval)
	
	script_execute(script, newval - value, true)
}

// Textbox
if (window_focus = string(tbx))
{
	if (textbox_draw(tbx, xx + capwid, yy + hei / 2 - 8, wid - capwid, 18))
		script_execute(script, clamp(snap(string_get_real(tbx.text, 0), snapval), minval, maxval), false)
}
else
	draw_label(string(value) + tbx.suffix, xx + capwid, yy + hei / 2, fa_left, fa_middle)
