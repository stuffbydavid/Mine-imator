/// draw_button_transition(x, y, transition)
/// @arg x
/// @arg y
/// @arg transition

var xx, yy, transition, mouseon, press, tipname;
xx = argument0
yy = argument1
transition = argument2
mouseon = app_mouse_box(xx, yy, 36, 36)
press = mouseon && mouse_left

draw_box(xx, yy, 36, 36, false, press ? c_accent_overlay : c_overlay, press ? a_accent_overlay : a_overlay)
draw_image(transition_texture_map[?transition], 0, xx, yy, 1, 1, c_text_secondary, a_text_secondary)

if (mouseon)
{
	draw_box_hover(xx, yy, 36, 36, 1)
	
	tipname = transition
	
	if (tipname != "linear" && tipname != "instant")
	{
		tipname = string_replace(tipname, "easeinout", "")
		tipname = string_replace(tipname, "easein", "")
		tipname = string_replace(tipname, "easeout", "")
		tipname = "ease" + tipname
	}
	
	tip_set(text_get("transition" + tipname), xx, yy, 36, 36)
	
	mouse_cursor = cr_handpoint
	
	if (mouse_left_released)
		return true				
}

return false