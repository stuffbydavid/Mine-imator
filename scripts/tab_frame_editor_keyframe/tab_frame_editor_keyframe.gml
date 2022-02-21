/// tab_frame_editor_keyframe()

function tab_frame_editor_keyframe()
{
	// Transition
	var trans, text;
	trans = tl_edit.value[e_value.TRANSITION]
	
	if (trans != "linear" && trans != "instant" && trans != "bezier")
	{
		if (string_contains(trans, "easeinout"))
		{
			trans = string_replace(trans, "easeinout", "")
			text = text_get("transitioneaseinout", text_get("transitionease" + trans))
		}
		
		if (string_contains(trans, "easein"))
		{
			trans = string_replace(trans, "easein", "")
			text = text_get("transitioneasein", text_get("transitionease" + trans))
		}
		
		if (string_contains(trans, "easeout"))
		{
			trans = string_replace(trans, "easeout", "")
			text = text_get("transitioneaseout", text_get("transitionease" + trans))
		}
	}
	else
		text = text_get("transition" + trans)
	
	tab_control_menu(32)
	draw_button_menu("frameeditortransition", e_menu.TRANSITION_LIST, dx, dy, dw, 32, tl_edit.value[e_value.TRANSITION], text, menu_transitions, false, transition_texture_small_map[?tl_edit.value[e_value.TRANSITION]])
	tab_next()
	
	// Bezier curve (Advanced mode only)
	if (tl_edit.value[e_value.TRANSITION] = "bezier" && setting_advanced_mode)
	{
		tab_control(208)
		
		var yy = dy;
		
		context_menu_group_temp = e_context_group.EASE
		
		// Ease in
		textfield_group_add("frameeditoreaseinx", floor(tl_edit.value[e_value.EASE_IN_X] * 100), 100, action_tl_frame_ease_in_x, X, tab.keyframe.tbx_ease_in_x, null, 0.5, 0, 100)
		textfield_group_add("frameeditoreaseiny", floor(tl_edit.value[e_value.EASE_IN_Y] * 100), 0, action_tl_frame_ease_in_y, X, tab.keyframe.tbx_ease_in_y, null, 0.5, -no_limit, no_limit)
		draw_textfield_group("frameeditoreasein", dx, yy, (dw/2) - 8, null, -no_limit, no_limit, 1, true, false, true)
		yy += (40 + label_height)
		
		// Ease out
		textfield_group_add("frameeditoreaseoutx", floor(tl_edit.value[e_value.EASE_OUT_X] * 100), 0, action_tl_frame_ease_out_x, X, tab.keyframe.tbx_ease_out_x, null, 0.5, 0, 100)
		textfield_group_add("frameeditoreaseouty", floor(tl_edit.value[e_value.EASE_OUT_Y] * 100), 100, action_tl_frame_ease_out_y, X, tab.keyframe.tbx_ease_out_y, null, 0.5, -no_limit, no_limit)
		draw_textfield_group("frameeditoreaseout", dx, yy, (dw/2) - 8, null, -no_limit, no_limit, 1, true, false, true)
		yy += (40 + label_height)
		
		// Link ease in/out
		if (draw_button_icon("frameeditorlinkeaseinout", dx, yy, 24, 24, tab.keyframe.ease_link, icons.LINK, null, false, "tooltiplinkeaseinout"))
			tab.keyframe.ease_link = !tab.keyframe.ease_link
		
		// Copy/paste/reset ease
		if (context_menu_name = "")
			context_menu_group = context_menu_group_temp
		
		draw_button_icon("frameeditoreasecopy", dx + 28, yy, 24, 24, false, icons.COPY, action_group_copy, false, "contextmenugroupcopy")
		draw_button_icon("frameeditoreasepaste", dx + (28 * 2), yy, 24, 24, false, icons.PASTE, action_group_paste, context_group_copy_list[|context_menu_group] = null, "contextmenugrouppaste")
		draw_button_icon("frameeditoreasereset", dx + (28 * 3), yy, 24, 24, false, icons.RESET, action_group_reset, false, "contextmenugroupreset")
		
		// Draw curve editor
		draw_bezier_graph(dx + dw/2, dy, dw/2, tab_control_h, [tl_edit.value[e_value.EASE_IN_X], tl_edit.value[e_value.EASE_IN_Y], tl_edit.value[e_value.EASE_OUT_X], tl_edit.value[e_value.EASE_OUT_Y]], tab.keyframe.ease_link)
		
		context_menu_group_temp = null
		
		tab_next()
	}
	
	// Visible
	tab_control_switch()
	draw_switch("frameeditorvisible", dx, dy, tl_edit.value[e_value.VISIBLE], action_tl_frame_visible)
	tab_next()
}
