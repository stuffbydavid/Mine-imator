function tab_frame_editor_keyframe()
{
	var animated, hidden;
	animated = tl_edit.animated
	hidden = tl_edit.hide
	
	if ((!animated || hidden) && tl_edit_amount > 1)
	{
		with (obj_timeline)
		{
			if (!selected)
				continue
			if (self.animated)
				animated = true
			if (!hide)
				hidden = false
		}
	}
	
	if (!animated)
	{
		draw_tooltip_label(tl_edit_amount > 1 ? "frameeditornotanimatedmultiple" : "frameeditornotanimated", icons.INFO, e_toast.INFO)
		dy += 8
		
		tab_control_button_label()
		if (draw_button_label("frameeditoranimated", dx + dw / 2, dy, null, null, e_button.PRIMARY, null, e_anchor.CENTER))
			action_tl_animated(true)
		tab_next()
		
		return 0
	}

	// Transition
	var transition = tl_edit.value[e_value.TRANSITION];
	if (transition != "linear" && transition != "instant" && transition != "bezier")
	{
		if (string_contains(transition, "easeinout"))
		{
			transition = string_replace(transition, "easeinout", "")
			content_text = text_get("transitioneaseinout", text_get("transitionease" + transition))
		}
		
		if (string_contains(transition, "easein"))
		{
			transition = string_replace(transition, "easein", "")
			content_text = text_get("transitioneasein", text_get("transitionease" + transition))
		}
		
		if (string_contains(transition, "easeout"))
		{
			transition = string_replace(transition, "easeout", "")
			content_text = text_get("transitioneaseout", text_get("transitionease" + transition))
		}
	}
	else
		content_text = text_get("transition" + transition)
	
	tab_control_menu(ui_large_height)
	draw_button_menu("frameeditortransition", e_menu.TRANSITION_LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TRANSITION], content_text, menu_transitions, false, transition_texture_small_map[?tl_edit.value[e_value.TRANSITION]])
	tab_next()
	
	// Bezier curve (Advanced mode only)
	if (tl_edit.value[e_value.TRANSITION] = "bezier" && setting_advanced_mode)
	{
		tab_control(208)
		
		var yy = dy;
		
		context_menu_group_temp = e_context_group.EASE
		
		// Ease in
		textfield_group_add("frameeditoreaseinx", floor(tl_edit.value[e_value.EASE_IN_X] * 100), 100, action_tl_frame_ease_in_x, X, tab.keyframe.tbx_ease_in_x, null, 0.5, 0, 100)
		textfield_group_add("frameeditoreaseiny", floor(tl_edit.value[e_value.EASE_IN_Y] * 100), 0, action_tl_frame_ease_in_y, Z, tab.keyframe.tbx_ease_in_y, null, 0.5, -no_limit, no_limit)
		draw_textfield_group("frameeditoreasein", dx, yy, (dw/2) - 8, null, -no_limit, no_limit, 1, false, true, 3)
		yy += (40 + label_height)
		
		// Ease out
		textfield_group_add("frameeditoreaseoutx", floor(tl_edit.value[e_value.EASE_OUT_X] * 100), 0, action_tl_frame_ease_out_x, X, tab.keyframe.tbx_ease_out_x, null, 0.5, 0, 100)
		textfield_group_add("frameeditoreaseouty", floor(tl_edit.value[e_value.EASE_OUT_Y] * 100), 100, action_tl_frame_ease_out_y, Z, tab.keyframe.tbx_ease_out_y, null, 0.5, -no_limit, no_limit)
		draw_textfield_group("frameeditoreaseout", dx, yy, (dw/2) - 8, null, -no_limit, no_limit, 1, false, true, 3)
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
	
	// Hidden status
	if (hidden)
		draw_tooltip_label(tl_edit_amount > 1 ? "frameeditorhiddenmultiple" : "frameeditorhidden", icons.INFO, e_toast.INFO)
}
