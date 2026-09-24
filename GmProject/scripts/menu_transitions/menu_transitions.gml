/// menu_transitions(x, y, width, height, menu)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg menu

function menu_transitions(xx, yy, wid, hei, menu = "all")
{
	var transition = null;
	dx_start = xx + 12
	dx = dx_start
	dy_start = yy
	dy = dy_start + 12
	
	// Other (Also in menu "easeinout")
	if (menu = "all")
	{
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
		dx = dx_start
		dy += 46
	}
	
	// Ease in
	if (menu = "easein" || menu = "all")
	{
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
	}
	
	// Ease out
	if (menu = "easeout" || menu = "all")
	{
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
	}
	
	if (menu = "easeinout" || menu = "all")
	{
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
	}
	
	// Other
	if (menu = "easeinout")
	{
		dy += 14
		draw_label(text_get("transitionmenuother"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_subheading)
		dy += 12
		
		for (var i = 0; i < ds_list_size(transition_list); i++)
		{
			if (string_contains(transition_list[|i], "bezier"))
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
	}
	
	// Save this transition as the new default for the quick button
	if ((settings_menu_name != "" || context_menu_name != "") && transition != null)
	{
		switch (menu)
		{
			case "easein": timeline.transition_easein = transition break;
			case "easeout": timeline.transition_easeout = transition break;
			case "easeinout": timeline.transition_easeinout = transition break;
		}
	}
	
	if (settings_menu_name != "" && transition != null) // Settings menu
	{
		action_tl_frame_transition(transition)
		settings_menu_ani_type = "hide"
		settings_menu_ani = (settings_menu_quick ? 0.01 : 1)
		window_busy = ""
		
		return true
	}
	
	if (context_menu_name != "" && transition != null) // Context menu
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
}
