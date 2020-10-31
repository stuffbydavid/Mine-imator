/// draw_meter(name, x, y, width, value, valuewidth, min, max, default, snap, textbox, script)
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

var name, xx, yy, wid, value, valuewid, minval, maxval, def, snapval, tbx, script;
var hei, linex, linewid, dragval, dragx, dragy, mouseon, locked;
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

valuewid = 48
hei = 30
locked = (minval = maxval)

if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	return 0

draw_label(text_get(name), xx, yy + 15, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_emphasis)
yy += 18

linex = xx + 6
linewid = wid - valuewid - 6

mouseon = app_mouse_box(xx - 8, yy, linewid + 16, hei) && content_mouseon

context_menu_area(linex, yy, linewid, hei, "contextmenuvalue", value, e_context_type.NUMBER, script, def)

// Click on meter
if (mouseon)
{
	mouse_cursor = cr_handpoint
	if (mouse_left_pressed) // Start dragging
	{
		window_busy = name
		window_focus = name
		meter_drag_value = value
	}
}

// Type
if (app_mouse_box(linex + linewid, yy, valuewid, hei) && content_mouseon && mouse_left_pressed)
{
	tbx.text = string_decimals(value)
	window_focus = string(tbx)
}

// Dragging
if (window_busy = name)
{
	mouse_cursor = cr_handpoint
	meter_drag_value = clamp(minval + (mouse_x - linex) * (max(1, (maxval - minval)) / linewid), minval, maxval)
	
	var d = snap(meter_drag_value, snapval) - value;
	if (d <> 0)
		script_execute(script, d, true)
		
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

microani_set(name, script, (window_busy = name) || mouseon, mouseon && mouse_left, false)

// Textbox
if (window_focus = string(tbx) && !locked)
{
	draw_set_font(font_value)
	var textsize = string_width(tbx.text);
	var suffixsize = string_width(tbx.suffix);
	if (textbox_draw(tbx, xx + wid - min(valuewid - 12, textsize + suffixsize), yy + hei / 2 - 8, min(valuewid - 12, textsize + suffixsize), 18))
	{
		var tbxval = string_get_real(tbx.text, 0)
		tbxval = clamp(tbxval, minval, maxval)
		
		script_execute(script, tbxval, false)
	}
}
else
	draw_label(string(value) + tbx.suffix, xx + wid, yy + hei / 2, fa_right, fa_middle, merge_color(c_text_main, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), lerp(a_text_main, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), font_value)

dragval = (window_busy = name ? meter_drag_value : value)

if (locked)
	dragx = .5 * linewid
else
	dragx = floor(percent(dragval, minval, maxval) * linewid)

dragy = yy + hei / 2

microani_update((window_busy = name) || mouseon, mouseon && mouse_left, false, locked)

// Snap markers
var markers = floor((maxval - minval) / snapval);
if (markers <= 32 && !locked)
{
	for (var i = 0; i < markers + 1; i++)
		draw_line_ext(linex + (linewid * (i / markers)), dragy - 6, linex + (linewid * (i / markers)), dragy + 6, c_border, a_border)
	
	// Snap dragger X
	dragx = snap(floor(percent(dragval, minval, maxval) * linewid), (linewid / markers))
}

// Line
draw_box(linex, dragy - 1, linewid + 1, 2, false, merge_color(c_text_secondary, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), lerp(a_text_secondary, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED]))
draw_box(linex, dragy - 1, dragx + 1, 2, false, c_accent, lerp(1, 0, mcroani_arr[e_mcroani.DISABLED]))

// Dragger
draw_box(linex + dragx - 6, dragy - 10, 12, 20, false, c_background, 1)
draw_box(linex + dragx - 6, dragy - 10, 12, 20, false, merge_color(c_accent, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED]), lerp(1, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED]))
draw_box_bevel(linex + dragx - 6, dragy - 10, 12, 20, 1)
draw_box_hover(linex + dragx - 6, dragy - 10, 12, 20, mcroani_arr[e_mcroani.HOVER] * (1 - mcroani_arr[e_mcroani.DISABLED]))
