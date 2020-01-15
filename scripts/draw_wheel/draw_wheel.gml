/// draw_wheel(name, x, y, color, value, min, max, default, snap, limit, textbox, script, [radius, sprite])
/// @arg name
/// @arg x
/// @arg y
/// @arg color
/// @arg value
/// @arg min
/// @arg max
/// @arg default
/// @arg snap
/// @arg limit
/// @arg textbox
/// @arg script
/// @arg [radius
/// @arg sprite]

var name, xx, yy, color, value, modval, minval, maxval, def, snapval, limit, tbx, script, rad, sprite;
var capwid, text, labelx, labely, labelw;
name = argument[0]
xx = argument[1]
yy = argument[2]
color = argument[3]
value = argument[4]
minval = (setting_unlimited_values ? -no_limit : argument[5])
maxval = (setting_unlimited_values ?  no_limit : argument[6])
def = argument[7]
snapval = argument[8]
limit = argument[9]
tbx = argument[10]
script = argument[11]

if (argument_count > 12)
{
	rad = argument[12]
	sprite = argument[13]
}
else
{
	rad = 40
	sprite = spr_circle_80
}

if (xx + rad < content_x || xx - rad > content_x + content_width || yy + rad < content_y || yy - rad > content_y + content_height)
	return 0

modval = mod_fix(value, 360)
capwid = string_width(text_get(name) + ":") + 5
if (limit)
	text = string(modval) + tbx.suffix
else
	text = string(value) + tbx.suffix
labelx = xx - floor(string_width(text) / 4)
labelw = rad
labely = yy + ((modval > 180 || modval = 0) ? -24 : 8)
tip_set(text_get(name + "tip") + "\n" + text_get("wheeltip"), xx - rad, yy - rad, rad * 2, rad * 2)

// Background
draw_image(sprite, 0, xx, yy, 1, 1, setting_color_background, 1)

// Bar
draw_image(spr_wheel_bar, 0, xx, yy, rad, 1, color, 1, value)
draw_image(spr_circle_6, 0, xx + lengthdir_x(rad, value), yy + lengthdir_y(rad, value), 1, 1, color, 1)
draw_image(spr_circle_8, 0, xx, yy, 1, 1, color, 1)

// Dragging
if (window_busy = name)
{
	mouse_cursor = cr_handpoint
	
	var angle1, angle2, newval;
	angle1 = point_direction(xx, yy, mouse_x, mouse_y)
	angle2 = point_direction(xx, yy, mouse_previous_x, mouse_previous_y)
	wheel_drag_value += angle_difference_fix(angle1, angle2)
	
	newval = clamp(snap(wheel_drag_value, snapval), minval, maxval)
	script_execute(script, newval - value, true)
	
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

// Click
if (app_mouse_box(xx - rad - 10, yy - rad - 10, rad * 2+20, rad * 2+20) && content_mouseon)
{
	mouse_cursor = cr_handpoint
	if (app_mouse_box(labelx, labely, labelw - 10, 16) && mouse_left_pressed)
	{
		tbx.text = string_decimals(value)
		window_focus = string(tbx)
	}
	else
	{
		if (mouse_left_pressed) // Start dragging
		{
			var newval = clamp(snap(value + angle_difference_fix(point_direction(xx, yy, mouse_x, mouse_y), value), snapval), minval, maxval)
			script_execute(script, newval - value, true)
			window_focus = name
			window_busy = name
			wheel_drag_value = newval
		}
		if (mouse_right_pressed)
			script_execute(script, def, false)
	}
}

// Mouse wheel
if (window_busy = "" && window_focus = name && mouse_wheel<>0)
{
	var newval;
	if (snapval = 0)
		newval = clamp(value - mouse_wheel * 5, minval, maxval)
	else
		newval = clamp(value - mouse_wheel * snapval, minval, maxval)
	
	script_execute(script, newval - value, true)
}

// Textbox
draw_label(text_get(name) + ":", labelx - capwid, labely)
if (window_focus = string(tbx))
{
	if (textbox_draw(tbx, labelx, labely, labelw, 18))
		script_execute(script, clamp(snap(string_get_real(tbx.text, 0), snapval), minval, maxval), false)
}
else
	draw_label(text, labelx, labely)
