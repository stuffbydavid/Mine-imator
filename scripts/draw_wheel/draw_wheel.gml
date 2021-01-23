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
var capwid, text, labelx, labely, labelw, labeltextw;
name = argument[0]
xx = argument[1]
yy = argument[2]
color = argument[3]
value = argument[4]
minval = argument[5]
maxval = argument[6]
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
	rad = 24
	sprite = spr_control_dial
}

if (xx + rad < content_x || xx - rad > content_x + content_width || yy + rad < content_y || yy - rad > content_y + content_height)
	return 0

context_menu_area(xx - rad, yy - rad, rad * 2, rad * 2, "contextmenuvalue", value, e_context_type.NUMBER, script, def)

draw_set_font(font_emphasis)

modval = mod_fix(value, 360)
capwid = string_width(text_get(name) + ":") + 5
if (limit)
{
	text = string_decimals(modval) + tbx.suffix
	
	if (floor(value/360) != 0)
		text = string(floor(value/360)) + "x" + text
}
else
	text = string_decimals(value) + tbx.suffix

draw_set_font(font_digits)

labelw = rad
labeltextw = capwid + string_width(text)
labelx = xx - (labeltextw/2) + capwid

labely = yy + 36

// Background
draw_image(sprite, 0, xx, yy, 1, 1, c_border, a_border)

// Bar
gpu_set_tex_filter(true)
draw_image(spr_dial_dash, 0, xx, yy, .5, .5, color, 1, value + 45)
gpu_set_tex_filter(false)

// Dragging
if (window_busy = name)
{
	mouse_cursor = cr_handpoint
	
	var angle1, angle2, newval;
	angle1 = point_direction(xx, yy, mouse_x, mouse_y)
	angle2 = point_direction(xx, yy, mouse_previous_x, mouse_previous_y)
	wheel_drag_value += angle_difference_fix(angle1, angle2) * dragger_multiplier
	
	newval = clamp(snap(wheel_drag_value, snapval), minval, maxval)
	script_execute(script, newval - value, true)
	
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
}

// Wheel click
if (app_mouse_box(xx - rad - 10, yy - rad - 10, rad * 2 + 20, rad * 2 + 20) && content_mouseon)
{
	mouse_cursor = cr_handpoint
	
	if (mouse_left_pressed) // Start dragging
	{
		var newval = clamp(snap(value + angle_difference_fix(point_direction(xx, yy, mouse_x, mouse_y), value), snapval), minval, maxval)
		script_execute(script, newval - value, true)
		window_focus = name
		window_busy = name
		wheel_drag_value = newval
	}
	
}

/*

// Textbox
draw_label(text_get(name) + ":", xx - (labeltextw/2), labely, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_emphasis)
draw_set_font(font_digits)
if (window_focus = string(tbx))
{
	if (textbox_draw(tbx, labelx, labely - 7, labeltextw, 18))
	{
		var str, loops, val;
		str = string_upper(tbx.text)
		
		// Parse loops
		if (limit && string_count("X", str) = 1)
		{
			var looppos, loopstr, valstr;
			looppos = string_pos("X", str)
			loopstr = string_copy(str, 1, looppos - 1)
			valstr = string_delete(str, 1, looppos)
			
			loops = string_get_real(loopstr, 0)
			val = string_get_real(valstr, 0) + (loops * 360)
		}
		else
			val = string_get_real(str, 0)
		
		script_execute(script, clamp(val, minval, maxval), false)
	}
}
else
	draw_label(text, labelx, labely - 7, fa_left, fa_top, c_text_main, a_text_main)

// Textbox click
if (app_mouse_box(labelx - capwid, labely - 7, labeltextw, 16))
{
	mouse_cursor = cr_handpoint
	
	if (mouse_left_pressed)
	{
		if (limit)
		{
			text = string_decimals(modval)
			
			if (floor(value/360) != 0)
				text = string(floor(value/360)) + "x" + text
			
			tbx.text = text
		}
		else
			tbx.text = string_decimals(value)
		
		window_focus = string(tbx)
	}
}
*/
