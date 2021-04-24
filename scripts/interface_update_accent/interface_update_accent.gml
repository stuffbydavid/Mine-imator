/// interface_update_accent()
/// @desc Updates accent variant colors

function interface_update_accent()
{
	c_accent_hover = merge_color(c_accent, c_white, .2)
	c_accent_pressed = merge_color(c_accent, c_black, .2)
	c_accent_overlay = c_accent
	c_hover = c_accent
}
