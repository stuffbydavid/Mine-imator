/// tab_control(height)
/// @arg height

tab_control_h = argument0
if (content_tab && content_direction = e_scroll.HORIZONTAL && dy + argument0 > dy_start + dh_start)
{
	dy = dy_start + 20
	if (dh = dh_start)
		dh -= 20
	dx += dw + 8
	return true
}

return false
