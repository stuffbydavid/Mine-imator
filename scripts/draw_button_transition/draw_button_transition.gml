/// draw_button_transition(x, y, transition)
/// @arg x
/// @arg y
/// @arg transition

function draw_button_transition(xx, yy, transition)
{
	var mouseon, press, active, tipname;
	mouseon = app_mouse_box(xx, yy, 36, 36)
	press = mouseon && mouse_left
	
	if (tl_edit != null)
		active = tl_edit.value[e_value.TRANSITION] = transition
	else
		active = false
	
	tipname = transition
	
	if (tipname != "linear" && tipname != "instant" && tipname != "bezier")
	{
		tipname = string_replace(tipname, "easeinout", "")
		tipname = string_replace(tipname, "easein", "")
		tipname = string_replace(tipname, "easeout", "")
		tipname = "ease" + tipname
	}
	
	// Advanced mode only
	if (transition = "bezier" && !setting_advanced_mode)
		return 0
	
	return draw_button_icon("menu" + transition, xx, yy, 36, 36, active, null, null, false, "transition" + tipname, transition_texture_map[?transition])
}
