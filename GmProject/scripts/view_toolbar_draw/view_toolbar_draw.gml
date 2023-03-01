/// view_toolbar_draw(view, x, y)
/// @arg view
/// @arg x
/// @arg y

function view_toolbar_draw(view, xx, yy)
{
	var width, height, starty, padding;
	width = 32
	height = view.toolbar_height
	starty = yy
	padding = 4
	
	if (yy + height > content_y + content_height)
	{
		view.toolbar_mouseon = bench_button_hover
		return 0
	}
	
	microani_prefix = string(view)
	
	if ((app_mouse_box(xx, yy, width, height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon)) || bench_button_hover)
		view.toolbar_mouseon = true
	else
		view.toolbar_mouseon = false
	
	if (view.toolbar_mouseon)
		content_mouseon = true
	
	if (app_mouse_box(xx - 64, yy - 64, width + 128, height + 128) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon))
		view.toolbar_alpha_goal = 1
	else
		view.toolbar_alpha_goal = .8
	
	if (window_busy = "bench")
		view.toolbar_alpha_goal = .8
	
	draw_set_alpha(view.toolbar_alpha)
	
	draw_dropshadow(xx, yy, width, height, c_black, 1)
	draw_box(xx, yy, width, height, false, c_level_top, 1)
	draw_outline(xx, yy, width, height, 1, c_border, a_border, true)
	
	xx += 4
	yy += 4
	
	tip_force_right = true
	
	// Select tool
	if (setting_separate_tool_modes)
	{
		tip_set_keybind(e_keybind.TOOL_SELECT)
		if (draw_button_icon("viewtoolselect", xx, yy, 24, 24, setting_tool_select, icons.SELECT, null, false, "viewtoolselecttip"))
		{
			action_tools_disable_all()
			setting_tool_select = true
		}
		yy += 24 + padding
	}
	
	// Position tool
	tip_set_keybind(e_keybind.TOOL_MOVE)
	
	if (draw_button_icon("viewtoolmove", xx, yy, 24, 24, setting_tool_move, icons.MOVE, null, false, "viewtoolmovetip"))
	{
		if (setting_separate_tool_modes)
		{
			action_tools_disable_all()
			setting_tool_move = true
		}
		else
		{
			setting_tool_move = !setting_tool_move
			setting_tool_scale = false
		}
	}
	yy += 24 + padding
	
	// Rotation tool
	tip_set_keybind(e_keybind.TOOL_ROTATE)
	
	if (draw_button_icon("viewtoolrotate", xx, yy, 24, 24, setting_tool_rotate, icons.ROTATE, null, false, "viewtoolrotatetip"))
	{
		if (setting_separate_tool_modes)
		{
			action_tools_disable_all()
			setting_tool_rotate = true
		}
		else
		{
			setting_tool_rotate = !setting_tool_rotate
			setting_tool_scale = false
		}
	}
	yy += 24 + padding
	
	// Scale tool (separate tool modes)
	if (setting_separate_tool_modes)
	{
		tip_set_keybind(e_keybind.TOOL_SCALE)
		if (draw_button_icon("viewtoolscale", xx, yy, 24, 24, setting_tool_scale, icons.SCALE, null, false, "viewtoolscaletip"))
		{
			if (setting_separate_tool_modes)
			{
				action_tools_disable_all()
				setting_tool_scale = true
			}
			else
			{
				setting_tool_scale = !setting_tool_scale
		
				if (setting_tool_scale)
				{
					setting_tool_move = false
					setting_tool_rotate = false
					setting_tool_bend = false
				}
			}
		}
		yy += 24 + padding
	}
	
	// Bend tool
	tip_set_keybind(e_keybind.TOOL_BEND)
	
	if (draw_button_icon("viewtoolbend", xx, yy, 24, 24, setting_tool_bend, icons.BEND, null, false, "viewtoolbendtip"))
	{
		if (setting_separate_tool_modes)
		{
			action_tools_disable_all()
			setting_tool_bend = true
		}
		else
		{
			setting_tool_bend = !setting_tool_bend
			setting_tool_scale = false
		}
	}
	yy += 24 + padding
	
	// Transform tool
	if (setting_separate_tool_modes)
	{
		tip_set_keybind(e_keybind.TOOL_TRANSFORM)
		if (draw_button_icon("viewtooltransform", xx, yy, 24, 24, setting_tool_transform, icons.MULTITRANSFORM, null, false, "viewtooltransformtip"))
		{
			action_tools_disable_all()
			setting_tool_transform = true
		}
		yy += 24 + padding
	}
	
	// Scale tool (toggleable tools)
	if (!setting_separate_tool_modes)
	{
		draw_divide(xx, yy, 24)
		yy += 1 + padding
		
		tip_set_keybind(e_keybind.TOOL_SCALE)
		if (draw_button_icon("viewtoolscale", xx, yy, 24, 24, setting_tool_scale, icons.SCALE, null, false, "viewtoolscaletip"))
		{
			if (setting_separate_tool_modes)
			{
				action_tools_disable_all()
				setting_tool_scale = true
			}
			else
			{
				setting_tool_scale = !setting_tool_scale
		
				if (setting_tool_scale)
				{
					setting_tool_move = false
					setting_tool_rotate = false
					setting_tool_bend = false
				}
			}
		}
		yy += 24 + padding
	}
	
	tip_force_right = false
	
	view.toolbar_height = yy - starty
	microani_prefix = ""
	
	draw_set_alpha(1)
}
