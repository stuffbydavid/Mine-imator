/// scrollbar_draw(scrollbar, direction, x, y, size, maxsize, color, pressedcolor, backcolor)
/// @arg scrollbar
/// @arg direction
/// @arg x
/// @arg y
/// @arg size
/// @arg maxsize
/// @arg color
/// @arg pressedcolor
/// @arg backcolor
/// @desc Draws the scrollbar.

var sb, dir, xx, yy, size, maxsize, color, pressedcolor, backcolor;
var margin, areasize, barsizeadj;
var barsize, barpos, mouseinarea, mouseinbar, pressed;
sb = argument0
dir = argument1
xx = argument2
yy = argument3
size = argument4
maxsize = argument5
color = argument6
pressedcolor = argument7
backcolor = argument8

margin = 10
barsizeadj = 10
areasize = margin * 2 + barsizeadj

size -= margin * 2
maxsize -= margin * 2
xx += margin
yy += margin

if (size >= maxsize || maxsize = 0)
{
    sb.needed = false
    sb.value = 0
}
else
    sb.needed = true
sb.atend = (sb.needed && sb.value >= maxsize - size)

if (!sb.needed || size < 5)
    return 0

barsize = clamp(5, floor((size / maxsize) * size), size)
barpos = min(size - barsize, floor(sb.value * (size / maxsize)))

if (dir = e_scroll.HORIZONTAL)
{
    mouseinarea = (app_mouse_box(xx - margin, yy - margin, size + margin * 2, areasize) && content_mouseon)
    mouseinbar = (app_mouse_box(xx - margin + barpos, yy - margin, barsize + margin * 2, areasize) && content_mouseon)
}
else
{
    mouseinarea = (app_mouse_box(xx - margin, yy - margin, areasize, size + margin * 2) && content_mouseon)
    mouseinbar = (app_mouse_box(xx - margin, yy - margin + barpos, areasize, barsize + margin * 2) && content_mouseon)
}

if (mouseinarea && window_busy = "")
{
    mouse_cursor = cr_handpoint
    if (mouse_left_pressed) // Start dragging
	{
        window_focus = string(sb)
        if (mouseinbar)
            window_busy = "scrollbar"
    }
	
    if (mouse_left && !mouseinbar) // Page jump
	{
        sb.press--
        if (sb.press < 1)
		{
            if (dir)
                sb.value += test(mouse_x < xx + barpos, -size, size)
            else
                sb.value += test(mouse_y < yy + barpos, -size, size)
            sb.value = snap(sb.value, sb.snap_value)
        }
		
        if (sb.press < 0)
            sb.press = 10
        else if (sb.press = 0)
            sb.press = 2
    }
}
if (!mouse_left)
    sb.press = 0

// Mouse wheel and dragging
if (window_focus = string(sb))
{
    if (window_busy = "")
	{
        if (sb.snap_value = 0)
            sb.value += mouse_wheel * 15
        else
            sb.value += mouse_wheel * sb.snap_value
    }
	
    if (window_busy = "scrollbar")
	{
        mouse_cursor = cr_handpoint
        if (!mouse_left)
		{
            window_busy = ""
            sb.value = snap(sb.value, sb.snap_value)
            app_mouse_clear()
        }
		else
		{
            if (dir = e_scroll.HORIZONTAL)
                sb.value += mouse_dx * (maxsize / size)
            else
                sb.value += mouse_dy * (maxsize / size)
        }
    }
}

sb.value = round(clamp(sb.value, 0, maxsize - size))
barpos = min(size - barsize, floor(sb.value * (size / maxsize)))
pressed = (window_busy = "scrollbar" && window_focus = string(sb))

if (dir = e_scroll.HORIZONTAL)
{
    draw_box(xx, yy, size, barsizeadj, false, backcolor, 1)
    draw_box(xx + barpos, yy, barsize, barsizeadj, false, test(pressed, pressedcolor, color), 1)    
}
else
{
    draw_box(xx, yy, barsizeadj, size, false, backcolor, 1)
    draw_box(xx, yy + barpos, barsizeadj, barsize, false, test(pressed, pressedcolor, color), 1)
}
