/// app_mouse_box_busy(x, y, width, height, busy)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg busy

function app_mouse_box_busy(xx, yy, w, h, busy) {

	return (mouse_x >= xx &&
			mouse_y >= yy &&
			mouse_x < xx + w &&
			mouse_y < yy + h && window_busy = busy && popup_ani_type = "")



}
