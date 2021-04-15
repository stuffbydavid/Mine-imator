/// app_mouse_wrap(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @desc Wraps mouse position in a box

var xx, yy, width, height, setx, sety, size;
xx = argument0
yy = argument1
width = argument2
height = argument3
setx = mouse_x
sety = mouse_y
size = 8

if ((mouse_x + (size/2)) < xx || display_mouse_get_x() < (size/2))
{
	setx = xx + width - size
	mouse_wrap_x--
}

if ((mouse_y + (size/2)) < yy || display_mouse_get_y() < (size/2))
{
	sety = yy + height - size
	mouse_wrap_y--
}

// Wrap on right
if (mouse_x > (xx + width - (size/2)) || (display_mouse_get_x() > (window_get_x() + window_get_width()) - (size/2)))
{
	setx = xx + size
	mouse_wrap_x++
}

// Wrap on bottom
if (mouse_y > (yy + height - (size/2)) || (display_mouse_get_y() > (window_get_y() + window_get_height()) - (size/2)))
{
	sety = yy + size
	mouse_wrap_y++
}

if (setx != mouse_x || sety != mouse_y)
{
	window_mouse_set(setx, sety)

	mouse_current_x = setx
	mouse_current_y = sety
}
