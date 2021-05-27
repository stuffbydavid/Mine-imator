/// tab_frame_editor_color()

function tab_frame_editor_color()
{
	if (!tl_edit.value_type[e_value_type.MATERIAL_COLOR])
		return 0
	
	context_menu_group_temp = e_context_group.COLOR
	
	// Alpha
	tab_control_meter()
	draw_meter("frameeditoropacity", dx, dy, dw, round(tl_edit.value[e_value.ALPHA] * 100), 56, 0, 100, 100, 1, tab.material.tbx_alpha, action_tl_frame_alpha)
	tab_next()
	
	tab_set_collumns(true, floor(content_width/150))
	
	if (tab.material.advanced)
	{
		// Mul
		tab_control_color()
		draw_button_color("frameeditorrgbmul", dx, dy, dw, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul)
		tab_next()
		
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
	}
	else
	{
		// Blend color
		tab_control_color()
		draw_button_color("frameeditorblendcolor", dx, dy, dw, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul)
		tab_next()
	}
	
	// Mix and glow color
	var glowenabled = tl_edit.glow && !tl_edit.value_type[e_value_type.CAMERA];
	
	tab_control_color()
	draw_button_color("frameeditormixcolor", dx, dy, dw, tl_edit.value[e_value.MIX_COLOR], c_black, false, action_tl_frame_mix_color)
	tab_next()
	
	if (glowenabled)
	{
		tab_control_color()
		draw_button_color("frameeditorglowcolor", dx, dy, dw, tl_edit.value[e_value.GLOW_COLOR], c_white, false, action_tl_frame_glow_color)
		tab_next()
	}	
	
	tab_set_collumns(false)
	
	tab_control_meter()
	draw_meter("frameeditormixpercent", dx, dy, dw, floor(tl_edit.value[e_value.MIX_PERCENT] * 100), 60, 0, 100, 0, 1, tab.material.tbx_mix_percent, action_tl_frame_mix_percent)
	tab_next()
	
	// Emission
	tab_control_meter()
	draw_meter("frameeditoremission", dx, dy, dw, round(tl_edit.value[e_value.BRIGHTNESS] * 100), 60, 0, 100, 0, 1, tab.material.tbx_brightness, action_tl_frame_brightness)
	tab_next()
	
	// Metallic
	tab_control_meter()
	draw_meter("frameeditormetallic", dx, dy, dw, round(tl_edit.value[e_value.METALLIC] * 100), 60, 0, 100, 0, 1, tab.material.tbx_metallic, action_tl_frame_metallic)
	tab_next()
	
	// Roughness
	tab_control_meter()
	draw_meter("frameeditorroughness", dx, dy, dw, round(tl_edit.value[e_value.ROUGHNESS] * 100), 60, 0, 100, 100, 1, tab.material.tbx_roughness, action_tl_frame_roughness)
	tab_next()
	
	#region Subsurface
	
	tab_control_switch()
	draw_button_collapse("material_subsurface", collapse_map[?"material_subsurface"], null, true, "frameeditorsubsurface")
	tab_next()
	
	if (collapse_map[?"material_subsurface"])
	{
		tab_collapse_start()
		
		// Subsurface radius
		tab_control_dragger()
		draw_dragger("frameeditorsubsurfaceradius", dx, dy, dragger_width, tl_edit.value[e_value.SUBSURFACE], .1, 0, no_limit, 0, 0.01, tab.material.tbx_subsurface, action_tl_frame_subsurface)
		tab_next()
	
		// Subsurface RGB radius
		textfield_group_add("frameeditorsubsurfaceradiusred", round(tl_edit.value[e_value.SUBSURFACE_RADIUS_RED] * 100), 100, action_tl_frame_subsurface_radius, X, tab.material.tbx_subsurface_radius[X])
		textfield_group_add("frameeditorsubsurfaceradiusgreen", round(tl_edit.value[e_value.SUBSURFACE_RADIUS_GREEN] * 100), 100, action_tl_frame_subsurface_radius, Y, tab.material.tbx_subsurface_radius[Y])
		textfield_group_add("frameeditorsubsurfaceradiusblue", round(tl_edit.value[e_value.SUBSURFACE_RADIUS_BLUE] * 100), 100, action_tl_frame_subsurface_radius, Z, tab.material.tbx_subsurface_radius[Z])
	
		tab_control_textfield(false)
		draw_textfield_group("frameeditorsubsurfaceradiusrgb", dx, dy, dw, 1, 0, 100, .1, false, true, true)
		tab_next()
	
		// Subsurface color
		tab_control_color()
		draw_button_color("frameeditorsubsurfacecolor", dx, dy, dw/2, tl_edit.value[e_value.SUBSURFACE_COLOR], c_white, false, action_tl_frame_subsurface_color)
		tab_next()
		
		tab_collapse_end()
	}
	
	#endregion
	
	context_menu_group_temp = null
}
