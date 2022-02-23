/// draw_help_circle(text, x, y, disabled)
/// @arg text
/// @arg x
/// @arg y
/// @arg disabled

function draw_help_circle(text, xx, yy, disabled)
{
	if (text = "")
		return 0
	
	var mouseon, color, alpha; 
	mouseon = app_mouse_box(xx, yy, 20, 20) && content_mouseon && !disabled
	
	microani_set(text, null, mouseon, false, false)
	color = merge_color(c_text_tertiary, c_text_secondary, microani_arr[e_microani.HOVER])
	alpha = lerp(a_text_tertiary, a_text_secondary, microani_arr[e_microani.HOVER]) * lerp(1, .5, microani_arr[e_microani.DISABLED])
	
	draw_image(spr_icons, icons.HELP_CIRCLE, xx + 10, yy + 10, 1, 1, color, alpha)
	
	if (!disabled)
		tip_set(text_get(text), xx, yy, 20, 20)
	
	microani_update(mouseon, false, false, disabled, 0)
}