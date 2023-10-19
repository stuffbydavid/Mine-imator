/// tab_frame_editor_color()

function tab_frame_editor_color()
{
	if (!tl_edit.value_type[e_value_type.MATERIAL_COLOR])
		return 0
	
	context_menu_group_temp = e_context_group.COLOR
	
	#region Texture settings
	
	// Have all settings exposed in 'Advanced mode'
	if (setting_advanced_mode)
	{
		tab_control_switch()
		draw_button_collapse("material_color", collapse_map[?"material_color"], null, true, "frameeditorcolor")
		tab_next()
	}
	
	if (collapse_map[?"material_color"] || !setting_advanced_mode)
	{
		if (setting_advanced_mode)
		{
			tab_collapse_start()
			tab_set_collumns(true, floor(content_width/150))
		}
		
		// Mul (/ Blend color)
		tab_control_color()
		draw_button_color("frameeditorblendcolor", dx, dy, dw, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul)
		tab_next()
		
		if (setting_advanced_mode)
		{
			tab_control_color()
			draw_button_color("frameeditorhsvmul", dx, dy, dw, tl_edit.value[e_value.HSB_MUL], c_white, true, action_tl_frame_hsb_mul)
			tab_next()
			
			// Add
			tab_control_color()
			draw_button_color("frameeditorrgbadd", dx, dy, dw, tl_edit.value[e_value.RGB_ADD], c_black, false, action_tl_frame_rgb_add)
			tab_next()
			
			tab_control_color()
			draw_button_color("frameeditorhsvadd", dx, dy, dw, tl_edit.value[e_value.HSB_ADD], c_black, true, action_tl_frame_hsb_add)
			tab_next()
			
			// Sub
			tab_control_color()
			draw_button_color("frameeditorrgbsub", dx, dy, dw, tl_edit.value[e_value.RGB_SUB], c_black, false, action_tl_frame_rgb_sub)
			tab_next()
			
			tab_control_color()
			draw_button_color("frameeditorhsvsub", dx, dy, dw, tl_edit.value[e_value.HSB_SUB], c_black, true, action_tl_frame_hsb_sub)
			tab_next()
			
			// Glow color
			var glowenabled = tl_edit.glow && !tl_edit.value_type[e_value_type.CAMERA];
			
			if (glowenabled)
			{
				tab_control_color()
				draw_button_color("frameeditorglowcolor", dx, dy, dw, tl_edit.value[e_value.GLOW_COLOR], c_white, false, action_tl_frame_glow_color)
				tab_next()
			}
			
			tab_set_collumns(false)
		}
		
		// Mix
		tab_control_color()
		draw_button_color("frameeditormixcolor", dx, dy, dw, tl_edit.value[e_value.MIX_COLOR], c_black, false, action_tl_frame_mix_color)
		tab_next()
		
		tab_control_meter()
		draw_meter("frameeditormixpercent", dx, dy, dw, floor(tl_edit.value[e_value.MIX_PERCENT] * 100), 0, 100, 0, 1, tab.material.tbx_mix_percent, action_tl_frame_mix_percent)
		tab_next()
		
		if (setting_advanced_mode)
			tab_collapse_end()
	}
	
	#endregion
	
	context_menu_group_temp = null
}
