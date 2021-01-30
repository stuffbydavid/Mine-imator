/// menu_transitions(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var xx, yy, wid, hei, transition;
xx = argument0
yy = argument1
wid = argument2
hei = argument3

dx_start = xx + 12
dx = dx_start
dy_start = yy
dy = dy_start + 12
transition = null

// Other
dy += 14
draw_label(text_get("transitionmenuother"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 12

for (var i = 0; i < ds_list_size(transition_list); i++)
{
	if (!string_contains(transition_list[|i], "ease"))
	{
		if (dx + 46 > xx + wid)
		{
			dx = dx_start
			dy += 46
		}
		
		if (draw_button_transition(dx, dy, transition_list[|i]))
			transition = transition_list[|i]
		
		dx += 46
	}
}
dy += 36 + 10
dx = dx_start

// Ease in
dy += 14
draw_label(text_get("transitionmenueasein"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 12

for (var i = 0; i < ds_list_size(transition_list); i++)
{
	if (string_contains(transition_list[|i], "easein") &&
		!string_contains(transition_list[|i], "easeinout"))
	{
		if (dx + 46 > xx + wid)
		{
			dx = dx_start
			dy += 46
		}
		
		if (draw_button_transition(dx, dy, transition_list[|i]))
			transition = transition_list[|i]
		
		dx += 46
	}
}
dx = dx_start
dy += 46

// Ease out
dy += 14
draw_label(text_get("transitionmenueaseout"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 12

for (var i = 0; i < ds_list_size(transition_list); i++)
{
	if (string_contains(transition_list[|i], "easeout"))
	{
		if (dx + 46 > xx + wid)
		{
			dx = dx_start
			dy += 46
		}
		
		if (draw_button_transition(dx, dy, transition_list[|i]))
			transition = transition_list[|i]
		
		dx += 46
	}
}
dx = dx_start
dy += 46

// Ease in & out
dy += 14
draw_label(text_get("transitionmenueaseinout"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
dy += 12

for (var i = 0; i < ds_list_size(transition_list); i++)
{
	if (string_contains(transition_list[|i], "easeinout"))
	{
		if (dx + 46 > xx + wid)
		{
			dx = dx_start
			dy += 46
		}
		
		if (draw_button_transition(dx, dy, transition_list[|i]))
			transition = transition_list[|i]
		
		dx += 46
	}
}
dx = dx_start
dy += 46

// Context menu
if (context_menu_name != "" && transition != null)
{
	action_tl_frame_transition(transition)
	context_menu_close()
	
	app_mouse_clear()
	
	return true
}
else if (transition != null) // Drop down menu
{
	action_tl_frame_transition(transition)
	
	menu_current.menu_ani = 1
	menu_current.menu_ani_type = "hide"
	window_busy = ""
	
	return true
}

return transition
