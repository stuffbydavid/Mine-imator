/// app_mouse_box_busy(x, y, width, height, busy)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg busy

return (mouse_x >= argument0 &&
		mouse_y >= argument1 &&
		mouse_x < argument0 + argument2 &&
		mouse_y < argument1 + argument3 && window_busy = argument4 && popup_ani_type = "")
