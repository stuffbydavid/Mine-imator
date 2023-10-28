/// app_mouse_box(x, y, width, height, [busy])
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function app_mouse_box(xx, yy, w, h, busy = "")
{
	return (mouse_x >= xx &&
			mouse_y >= yy &&
			mouse_x < xx + w &&
			mouse_y < yy + h && (window_busy = "" || window_busy = busy) && popup_ani_type = "")
}
