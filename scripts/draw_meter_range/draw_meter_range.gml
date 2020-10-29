/// draw_meter_range(name, x, y, width, min, max, snap, valuemin, valuemax, defaultmin, defaultmax, textboxmin, textboxmax, scriptmin, scriptmax)
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg min
/// @arg max
/// @arg snap
/// @arg valuemin
/// @arg valuemax
/// @arg defaultmin
/// @arg defaultmax
/// @arg textboxmin
/// @arg textboxmax
/// @arg scriptmin
/// @arg scriptmax

var name, xx, yy, wid, minval, maxval, snapval, valuemin, valuemax, defmin, defmax, tbxmin, tbxmax, scriptmin, scriptmax;
var hei, linex, linewid, dragxmin, dragxmax, dragy, mouseon, mouseonmin, mouseonmax;
name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
minval = argument[4]
maxval = argument[5]
snapval = argument[6]
valuemin = argument[7]
valuemax = argument[8]
defmin = argument[9]
defmax = argument[10]
tbxmin = argument[11]
tbxmax = argument[12]
scriptmin = argument[13]
scriptmax = argument[14]

valuewid = 48
hei = 30

if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	return 0

// Caption
draw_label(text_get(name), xx, yy + 15, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)
yy += 18

linewid = wid - (valuewid * 2)
linex = xx + valuewid
mouseon = app_mouse_box(linex - 8, yy, linewid + 16, hei) && content_mouseon
draw_set_font(font_value)

// Type(Minimum)
if (app_mouse_box(xx, yy, valuewid, hei) && content_mouseon && mouse_left_pressed)
{
	tbxmin.text = string_decimals(valuemin)
	window_focus = string(tbxmin)
}

// Type(Maximum)
if (app_mouse_box(linex + linewid, yy, valuewid, hei) && content_mouseon && mouse_left_pressed)
{
	tbxmax.text = string_decimals(valuemax)
	window_focus = string(tbxmax)
}

// Dragging
if (window_busy = name + "min" || window_busy = name + "max")
{
	mouse_cursor = cr_handpoint
	meter_drag_value = clamp(minval + (mouse_x - linex) * (max(1, (maxval - minval)) / linewid), minval, maxval)
	
	if (window_busy = name + "min")
	{
		var d = min(snap(meter_drag_value, snapval), valuemax) - valuemin;
		if (d <> 0)
			script_execute(scriptmin, d, true)
	}
	else
	{
		var d = max(snap(meter_drag_value, snapval), valuemin) - valuemax;
		if (d <> 0)
			script_execute(scriptmax, d, true)
	}
	
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

// Textbox(Minimum)
if (window_focus = string(tbxmin))
{
	var textsize = string_width(tbxmin.text);
	var suffixsize = string_width(tbxmin.suffix);
	if (textbox_draw(tbxmin, xx, yy + hei / 2 - 8, textsize + suffixsize, 18))
	{
		var tbxval = string_get_real(tbxmin.text, 0)
		tbxval = clamp(tbxval, minval, maxval)
		tbxval = min(tbxval, valuemax)
		
		script_execute(scriptmin, tbxval, false)
	}
}
else
	draw_label(string_decimals(valuemin) + tbxmin.suffix, xx, yy + hei / 2, fa_left, fa_middle, c_text_main, a_text_main)

// Textbox(Maximum)
if (window_focus = string(tbxmax))
{
	var textsize = string_width(tbxmax.text);
	var suffixsize = string_width(tbxmax.suffix);
	if (textbox_draw(tbxmax, xx + wid - textsize - suffixsize, yy + hei / 2 - 8, textsize + suffixsize, 18))
	{
		var tbxval = string_get_real(tbxmax.text, 0)
		tbxval = clamp(tbxval, minval, maxval)
		tbxval = max(tbxval, valuemin)
		
		script_execute(scriptmax, tbxval, false)
	}
}
else
	draw_label(string_decimals(valuemax) + tbxmax.suffix, xx + wid, yy + hei / 2, fa_right, fa_middle, c_text_main, a_text_main)

dragxmin = (window_busy = name + "min" ? meter_drag_value : valuemin)
dragxmax = (window_busy = name + "max" ? meter_drag_value : valuemax)

dragy = yy + hei / 2

// Snap thumbs
dragxmin = floor(percent(dragxmin, minval, maxval) * linewid)
dragxmax = floor(percent(dragxmax, minval, maxval) * linewid)
mouseonmin = app_mouse_box(linex + dragxmin - 6, dragy - 10, 12, 20)
mouseonmax = app_mouse_box(linex + dragxmax - 6, dragy - 10, 12, 20)

// Click on thumbs
if (mouseon && window_busy = "")
{
	mouse_cursor = cr_handpoint
	if (mouse_left_pressed) // Start dragging
	{
		if (mouseonmin)
		{
			window_busy = name + "min"
			meter_drag_value = valuemin
		}
		else if (mouseonmax)
		{
			window_busy = name + "max"
			meter_drag_value = valuemax
		}
		window_focus = name
	}
	
	if (mouse_right_pressed)
	{
		script_execute(scriptmin, defmin, false)
		script_execute(scriptmax, defmax, false)
	}
}

// Line
if (window_busy = name + "min")
	dragxmin = min(dragxmin, dragxmax)
if (window_busy = name + "max")
	dragxmax = max(dragxmin, dragxmax)

draw_box(linex, dragy - 1, dragxmin + 1, 2, false, c_text_secondary, a_text_secondary)
draw_box(linex + dragxmin, dragy - 1, (dragxmax - dragxmin) + 1, 2, false, c_accent, 1)
draw_box(linex + dragxmax, dragy - 1, (linewid - dragxmax) + 1, 2, false, c_text_secondary, a_text_secondary)

microani_set(name + "min", scriptmin, (window_busy = name + "min") || mouseonmin, mouseonmin && mouse_left, false)
microani_update((window_busy = name + "min") || mouseonmin, mouseonmin && mouse_left, false)

// Dragger(Minimum)
draw_box(linex + dragxmin - 6, dragy - 10, 12, 20, false, c_accent, 1)
draw_box_bevel(linex + dragxmin - 6, dragy - 10, 12, 20, 1)
draw_box_hover(linex + dragxmin - 6, dragy - 10, 12, 20, mcroani_arr[e_mcroani.HOVER])

microani_set(name + "max", scriptmax, (window_busy = name + "max") || mouseonmax, mouseonmax && mouse_left, false)
microani_update((window_busy = name + "max") || mouseonmax, mouseonmax && mouse_left, false)

// Dragger(Maximum)
draw_box(linex + dragxmax - 6, dragy - 10, 12, 20, false, c_accent, 1)
draw_box_bevel(linex + dragxmax - 6, dragy - 10, 12, 20, 1)
draw_box_hover(linex + dragxmax - 6, dragy - 10, 12, 20, mcroani_arr[e_mcroani.HOVER])
