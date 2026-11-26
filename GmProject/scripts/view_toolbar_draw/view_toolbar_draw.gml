/// @arg view

function view_toolbar_draw(view)
{
	var xx, yy, padding, wid, hei, starty;
	xx = content_x + 16
	yy = content_y + 16 + 86 + 12
	padding = 6
	wid = 24 + padding * 2
	hei = view.toolbar_height
	starty = yy
	
	if (yy + hei > content_y + content_height)
	{
		view.toolbar_mouseon = bench_button_hover
		return 0
	}
	
	microani_prefix = string(view)
	
	if ((app_mouse_box(xx, yy, wid, hei) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon)) || bench_button_hover)
		view.toolbar_mouseon = true
	else
		view.toolbar_mouseon = false
	
	if (view.toolbar_mouseon)
		content_mouseon = true
	
	if (app_mouse_box(xx - 64, yy - 64, wid + 128, hei + 128) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon && !(view_second.show && view_second.mouseon))
		view.toolbar_alpha_goal = 1
	else
		view.toolbar_alpha_goal = .8
	
	if (window_busy = "bench")
		view.toolbar_alpha_goal = .8
	
	draw_set_alpha(view.toolbar_alpha)
	
	draw_box_rounded(xx, yy, wid, hei, c_level_top, 1)
	
	xx += padding
	yy += padding
	
	tip_force_right = true
	
	// Build tool
	tip_set_keybind(e_keybind.BUILD_TOOL)
		
	if (draw_button_icon("view/tool/build", xx, yy, 24, 24, place_build, icons.BLOCK, null, false, "view/tool/build_tip"))
		action_toolbar_build_mode()
		
	yy += 24 + padding
		
	draw_divide(xx, yy, 24)
		
	yy += 1 + padding
	
	if (!place_build)
	{
		// Select tool
		if (setting_separate_tool_modes)
		{
			tip_set_keybind(e_keybind.TOOL_SELECT)
		
			if (draw_button_icon("view/tool/select", xx, yy, 24, 24, setting_tool_select, icons.SELECT, null, false, "view/tool/select_tip"))
			{
				action_tools_disable_all()
				setting_tool_select = true
			}
		
			yy += 24 + padding
		}
	
		// Position tool
		tip_set_keybind(e_keybind.TOOL_MOVE)
	
		if (draw_button_icon("view/tool/move", xx, yy, 24, 24, setting_tool_move, icons.MOVE, null, false, "view/tool/move_tip"))
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
	
		if (draw_button_icon("view/tool/rotate", xx, yy, 24, 24, setting_tool_rotate, icons.ROTATE, null, false, "view/tool/rotate_tip"))
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
		
			if (draw_button_icon("view/tool/scale", xx, yy, 24, 24, setting_tool_scale, icons.SCALE, null, false, "view/tool/scale_tip"))
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
	
		if (draw_button_icon("view/tool/bend", xx, yy, 24, 24, setting_tool_bend, icons.BEND, null, false, "view/tool/bend_tip"))
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
		
			if (draw_button_icon("view/tool/transform", xx, yy, 24, 24, setting_tool_transform, icons.MULTITRANSFORM, null, false, "view/tool/transform_tip"))
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
		
			if (draw_button_icon("view/tool/scale", xx, yy, 24, 24, setting_tool_scale, icons.SCALE, null, false, "view/tool/scale_tip"))
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
	}
	else
	{
		tip_set_keybind(e_keybind.BUILD_FIRST_PERSON)
	
		if (draw_button_icon("view/tool/first_person", xx, yy, 24, 24, build_first_person, icons.DRAG_LEFT, null, false, "view/tool/first_person_tip"))
			action_build_first_person(!build_first_person)
	
		yy += 24 + padding

		// Block timeline placement
		var blocktl, disabled;
		disabled = (build_tool.build_selected = null)
		blocktl = (build_tool.build_selected != null && (build_timeline_required || build_timeline != keyboard_check(vk_control)))
		tip_set_keybind(keybind_new(vk_control))

		if (draw_button_icon("view/tool/block_timeline", xx, yy, 24, 24, blocktl, icons.BLOCK_TIMELINE, null, disabled, "view/tool/block_timeline_tip"))
			build_timeline = (build_timeline_required || !build_timeline)

		yy += 24 + padding
	}
	
	tip_force_right = false
	
	view.toolbar_height = yy - starty
	microani_prefix = ""
	
	draw_set_alpha(1)
}
