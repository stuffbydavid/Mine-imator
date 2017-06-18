/// draw_wheel_sky(name, x, y, value, default, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg value
/// @arg default
/// @arg script

var name, xx, yy, value, def, script;
var rad, sunx, suny, moonx, moony, moonmouseon;
name = argument0
xx = argument1
yy = argument2
value = argument3
def = argument4
script = argument5

rad = 50
if (xx + rad < content_x || xx - rad > content_x + content_width || yy + rad < content_y || yy - rad > content_y + content_height)
    return 0

tip_set(text_get(name + "tip") + "\n" + text_get("wheelskytip"), xx - rad, yy - rad, rad * 2, rad * 2)
draw_image(spr_circle_100, 0, xx, yy, 1, 1, setting_color_background, 1)
draw_label(text_get(name), xx, yy, fa_center, fa_middle)

// Sun
sunx = floor(xx + lengthdir_x(rad, value + 90))
suny = floor(yy + lengthdir_y(rad, value + 90))
draw_image(spr_sun, 0, sunx, suny, 2, 2)

// Moon
moonx = floor(xx + lengthdir_x(rad, value - 90))
moony = floor(yy + lengthdir_y(rad, value - 90))
moonmouseon = (app_mouse_box(moonx - 32, moony - 32, 64, 64) && content_mouseon)
draw_image(spr_moon, 0, moonx, moony, 2, 2)

// Click
if (app_mouse_box(xx - rad - 10, yy - rad - 10, rad * 2+20, rad * 2+20) && content_mouseon)
{
    mouse_cursor = cr_handpoint
	
    if (mouse_left_pressed) // Start dragging
	{
        window_focus = name
        window_busy = name
        wheel_drag_moon = moonmouseon // Drag moon?
		
        if (!wheel_drag_moon)
		{
            var add = angle_difference_fix(point_direction(xx, yy, mouse_x, mouse_y) - 90, value);
            script_execute(script, add, true)
        }
    }
	
    if (mouse_right_pressed)
        script_execute(script, def, false)
}

// Dragging
if (window_busy = name)
{
    var angle1, angle2, add;
    mouse_cursor = cr_handpoint
    angle1 = point_direction(xx, yy, mouse_x, mouse_y) - 90
    angle2 = point_direction(xx, yy, mouse_previous_x, mouse_previous_y) - 90
    add = angle_difference_fix(angle1, angle2)
    script_execute(script, add, true)
	
    if (!mouse_left)
	{
        window_busy = ""
        app_mouse_clear()
    }
}

// Mouse wheel
if (window_busy = "" && window_focus = name && mouse_wheel<>0)
    script_execute(script, mouse_wheel * 10, true)
