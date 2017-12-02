/// draw_meter(name, x, y, width, value, valuewidth, min, max, default, snap, textbox, script, [captionwidth, [tip]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg value
/// @arg valuewidth
/// @arg min
/// @arg max
/// @arg default
/// @arg snap
/// @arg textbox
/// @arg script
/// @arg [captionwidth
/// @arg [tip]]

var name, xx, yy, wid, value, valuewid, minval, maxval, def, snapval, tbx, script, capwid, tip;
var hei, linewid, dragval, dragx, dragy;
name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
value = argument[4]
valuewid = argument[5]
minval = argument[6]
maxval = argument[7]
def = argument[8]
snapval = argument[9]
tbx = argument[10]
script = argument[11]

hei = 30
if (xx + wid<content_x || xx > content_x + content_width || yy + hei<content_y || yy > content_y + content_height)
	return 0
	
if (argument_count > 12)
	capwid = argument[12]
else
	capwid = text_caption_width(name)
	
if (argument_count > 13)
	tip = argument[13]
else
	tip = text_get(name + "tip")
	
tip += "\n" + text_get("metertip")
	
linewid = wid-capwid - valuewid
if (window_focus != string(tbx))
	tip_set(tip, xx, yy, wid, hei)
	
// Click on meter
if (app_mouse_box(xx + capwid - 8, yy, linewid + 16, hei) && content_mouseon)
{
	mouse_cursor = cr_handpoint
	if (mouse_left_pressed) // Start dragging
	{
		window_busy = name
		window_focus = name
		meter_drag_value = value
	}
	if (mouse_right_pressed && def != no_limit)
		script_execute(script, def, false)
}

// Type
if (app_mouse_box(xx + wid-valuewid + 8, yy, valuewid - 8, hei) && content_mouseon && mouse_left_pressed)
{
	tbx.text = string_decimals(value)
	window_focus = string(tbx)
}

// Dragging
if (window_busy = name)
{
	mouse_cursor = cr_handpoint
	meter_drag_value = clamp(minval + (mouse_x - (xx + capwid)) * (max(1, (maxval - minval)) / linewid), minval, maxval)
	
	var d = snap(meter_drag_value, snapval) - value;
	if (d <> 0)
		script_execute(script, d, true)
		
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

// Mouse wheel
if (window_busy = "" && window_focus = name && mouse_wheel<>0)
{
	if (snapval = 0)
		script_execute(script, clamp(value - mouse_wheel, minval, maxval) - value, true)
	else
		script_execute(script, clamp(value - mouse_wheel * snapval * 5, minval, maxval) - value, true)
}

// Caption
draw_label(text_get(name) + ":", xx, yy + hei / 2, fa_left, fa_middle)

// Textbox
if (window_focus = string(tbx))
{
	if (textbox_draw(tbx, xx + wid - valuewid + 16, yy + hei / 2 - 8, valuewid - 16, 18))
	{
		var tbxval = string_get_real(tbx.text, 0)
		tbxval = clamp(tbxval, minval, maxval)
		tbxval = snap(tbxval, snapval)
		script_execute(script, tbxval, false)
	}
}
else
	draw_label(string(value) + tbx.suffix, xx + wid-valuewid + 16, yy + hei / 2, fa_left, fa_middle)
	
dragval = test(window_busy = name, meter_drag_value , value)
dragx = xx + capwid + floor(percent(dragval, minval, maxval) * linewid)
dragy = yy + hei / 2

// Line
draw_image(spr_meter, 0, xx + capwid, dragy, 1, 1, setting_color_buttons, 1)
draw_image(spr_meter, 1, xx + capwid + 2, dragy, dragx - (xx + capwid) - 2, 1, setting_color_buttons, 1)
draw_image(spr_meter, 1, dragx, dragy, (xx + capwid + linewid) - dragx - 2, 1, setting_color_background, 1)
draw_image(spr_meter, 2, xx + capwid + linewid - 2, dragy, 1, 1, setting_color_background, 1)

// Dragger
draw_image(spr_circle_12, 0, dragx, dragy, 1, 1, test(window_busy = name, setting_color_buttons_pressed, setting_color_buttons), 1)
