/// scrollbar_draw(scrollbar, direction, x, y, size, maxsize)
/// @arg scrollbar
/// @arg direction
/// @arg x
/// @arg y
/// @arg size
/// @arg maxsize
/// @desc Draws a scrollbar.

function scrollbar_draw(sb, dir, xx, yy, size, maxsize)
{
	var margin, width, areasize, nearsize;
	var barsize, barpos, mouseinarea, mouseinbar, mousenear, pressed;
	
	width = 6
	margin = 3
	areasize = (width + (margin * 2))
	nearsize = 0
	
	if (size >= maxsize || maxsize = 0)
	{
		sb.needed = false
		sb.value = 0
		sb.value_goal = 0
	}
	else
		sb.needed = true
	
	sb.atend = (sb.needed && sb.value >= maxsize - size)
	
	if (!sb.needed || size < 5)
		return 0
	
	// Animate size
	if (dir = e_scroll.HORIZONTAL)
		sb.mousenear.value = (app_mouse_box(xx, yy - nearsize, size, areasize + nearsize) && content_mouseon) || (window_focus = string(sb) && window_busy = "scrollbar")
	else
		sb.mousenear.value = (app_mouse_box(xx - nearsize, yy, areasize + nearsize, size) && content_mouseon) || (window_focus = string(sb) && window_busy = "scrollbar")
	
	var xfar, yfar, xnear, ynear;
	xfar = xx + margin
	yfar = yy + margin
	
	if (dir = e_scroll.HORIZONTAL)
	{
		xnear = xfar
		ynear = yy
	}
	else
	{
		xnear = xx
		ynear = yfar
	}
	
	width += ((margin * 2) * sb.mousenear.value_ani_ease)
	xx = lerp(xfar, xnear, sb.mousenear.value_ani_ease)
	yy = lerp(yfar, ynear, sb.mousenear.value_ani_ease)
	size -= (margin * 2)
	maxsize -= (margin * 2)
	
	barsize = clamp(16, floor((size / maxsize) * size), size)
	barpos = min(size - barsize, floor(sb.value * (size / maxsize)))
	
	if (dir = e_scroll.HORIZONTAL)
	{
		mouseinarea = (app_mouse_box(xx - margin, yy - margin, size + (margin * 2), areasize) && content_mouseon)
		mouseinbar = (app_mouse_box(xx + barpos, yy, barsize, width) && content_mouseon)
	}
	else
	{
		mouseinarea = (app_mouse_box(xx - margin, yy - margin, areasize, size + (margin * 2)) && content_mouseon)
		mouseinbar = (app_mouse_box(xx, yy + barpos, width, barsize) && content_mouseon)
	}
	
	sb.mouseon = mouseinarea
	
	if (mouseinarea)
	{
		mouse_cursor = cr_handpoint
		
		if (!mouse_left_pressed && mouse_left && !mouseinbar && (dir ? (mouse_x < (xx + barpos) || mouse_x > (xx + barpos + barsize)) : (mouse_y < (yy + barpos) || mouse_y > (yy + barpos + barsize)))) // Page jump
		{
			sb.press--
			if (sb.press < 1)
			{
				if (dir)
					sb.value_goal += ((mouse_x < xx + barpos) ? -size : size) / 4
				else
					sb.value_goal += ((mouse_y < yy + barpos) ? -size : size) / 4
				
				sb.value_goal = snap(sb.value_goal, sb.snap_value)
				sb.value = snap(sb.value, sb.snap_value)
			}
			
			if (sb.press < 0)
				sb.press = 10
			else if (sb.press = 0)
				sb.press = 2
		}
		else if (mouse_left && mouseinbar) // Start dragging
		{
			window_focus = string(sb)
			window_busy = "scrollbar"
		}
	}
	if (!mouse_left)
		sb.press = 0
	
	// Mouse wheel
	if (window_busy = "" && content_mouseon)
	{	
		if (window_scroll_focus_prev = string(sb))
		{
			if (sb.snap_value = 0)
				sb.value_goal += mouse_wheel * 120
			else
				sb.value_goal += (mouse_wheel * sb.snap_value) * 4
		}
	}
	
	// Dragging
	if (window_focus = string(sb) || (window_focus = "" && content_mouseon))
	{
		if (window_busy = "scrollbar")
		{
			mouse_cursor = cr_handpoint
			if (!mouse_left)
			{
				window_busy = ""
				//window_focus = ""
				sb.value = snap(sb.value, sb.snap_value)
				sb.value_goal = snap(sb.value_goal, sb.snap_value)
				app_mouse_clear()
			}
			else
			{
				if (dir = e_scroll.HORIZONTAL)
				{
					sb.value += mouse_dx * (maxsize / size)
					sb.value_goal = sb.value
				}
				else
				{
					sb.value += mouse_dy * (maxsize / size)
					sb.value_goal = sb.value
				}
			}
		}
	}
	
	sb.value = floor(clamp(sb.value, 0, maxsize - size))
	sb.value_goal = floor(clamp(sb.value_goal, 0, maxsize - size))
	
	barpos = min(size - barsize, floor(sb.value * (size / maxsize)))
	pressed = (window_busy = "scrollbar" && window_focus = string(sb))
	
	if (dir = e_scroll.HORIZONTAL)
	{
		draw_box(xx, yy, size, width, false, c_overlay, a_overlay)
		draw_box(xx + barpos, yy, barsize, width, false, c_accent, 1)
	}
	else
	{
		draw_box(xx, yy, width, size, false, c_overlay, a_overlay)
		draw_box(xx, yy + barpos, width, barsize, false, c_accent, 1)
	}
}
