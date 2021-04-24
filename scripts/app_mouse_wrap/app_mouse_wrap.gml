/// app_mouse_wrap(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @desc Wraps mouse position in a box

function app_mouse_wrap(xx, yy, w, h)
{
	var setx, sety, size;
	setx = mouse_x
	sety = mouse_y
	size = 8
	
	if ((mouse_x + (size/2)) < xx || display_mouse_get_x() < (size/2))
	{
		setx = xx + w - size
		mouse_wrap_x--
	}
	
	if ((mouse_y + (size/2)) < yy || display_mouse_get_y() < (size/2))
	{
		sety = yy + h - size
		mouse_wrap_y--
	}
	
	// Wrap on right
	if (mouse_x > (xx + w - (size/2)) || (display_mouse_get_x() > (window_get_x() + window_get_width()) - (size/2)))
	{
		setx = xx + size
		mouse_wrap_x++
	}
	
	// Wrap on bottom
	if (mouse_y > (yy + h - (size/2)) || (display_mouse_get_y() > (window_get_y() + window_get_height()) - (size/2)))
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
}
