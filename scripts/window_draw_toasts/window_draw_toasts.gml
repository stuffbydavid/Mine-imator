/// window_draw_toasts()
/// @desc Draws all active toasts

var toast;

toast_mouseon = false

for (var i = toast_amount - 1; i >= 0; i--)
{
	toast = toast_list[|i]
	
	draw_set_alpha(ease("easeoutcirc", toast.remove_alpha))
	toast_draw(toast)
	draw_set_alpha(1)
}