/// @arg mixtextbox

function tab_frame_editor_color(mixtbx, showmix = true)
{
	if (!tl_edit.value_type[e_value_type.MATERIAL_COLOR] && !(tl_edit.type = e_tl_type.CAMERA_EFFECT && tl_edit.camera_effect_type = e_cam_fx.COLOR_CORRECTION))
		return 0
	
	context_menu_group_temp = e_context_group.COLOR
	
	#region Color settings
	
	// Have all settings exposed in 'Advanced mode'
	if (setting_advanced_mode)
	{
		tab_control_switch()
		draw_button_collapse("frame_editor/material_color", collapse_map[?"frame_editor/material_color"], null, true, "frame_editor/color")
		tab_next()
	}
	
	if (collapse_map[?"frame_editor/material_color"] || !setting_advanced_mode)
	{
		if (setting_advanced_mode)
		{
			tab_collapse_start()
			tab_set_columns(true, floor(content_width/150))
		}
		
		// Mul (/ Blend color)
		tab_control_color()
		draw_button_color("frame_editor/blend_color", dx, dy, dw, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul)
		tab_next()
		
		if (setting_advanced_mode)
		{
			tab_control_color()
			draw_button_color("frame_editor/hsv_mul", dx, dy, dw, tl_edit.value[e_value.HSB_MUL], c_white, true, action_tl_frame_hsb_mul)
			tab_next()
			
			// Add
			tab_control_color()
			draw_button_color("frame_editor/rgb_add", dx, dy, dw, tl_edit.value[e_value.RGB_ADD], c_black, false, action_tl_frame_rgb_add)
			tab_next()
			
			tab_control_color()
			draw_button_color("frame_editor/hsv_add", dx, dy, dw, tl_edit.value[e_value.HSB_ADD], c_black, true, action_tl_frame_hsb_add)
			tab_next()
			
			// Sub
			tab_control_color()
			draw_button_color("frame_editor/rgb_sub", dx, dy, dw, tl_edit.value[e_value.RGB_SUB], c_black, false, action_tl_frame_rgb_sub)
			tab_next()
			
			tab_control_color()
			draw_button_color("frame_editor/hsv_sub", dx, dy, dw, tl_edit.value[e_value.HSB_SUB], c_black, true, action_tl_frame_hsb_sub)
			tab_next()
			
			// Glow color
			var glowenabled = (tl_edit.glow && !tl_edit.value_type[e_value_type.CAMERA] && !tl_edit.value_type[e_value_type.CAMERA_EFFECT]);
			if (glowenabled)
			{
				tab_control_color()
				draw_button_color("frame_editor/glow_color", dx, dy, dw, tl_edit.value[e_value.GLOW_COLOR], c_white, false, action_tl_frame_glow_color)
				tab_next()
			}
			
			tab_set_columns(false)
		}
		
		if (showmix)
		{
			// Mix
			tab_control_color()
			draw_button_color("frame_editor/mix_color", dx, dy, dw, tl_edit.value[e_value.MIX_COLOR], c_black, false, action_tl_frame_mix_color)
			tab_next()

			tab_control_meter()
			draw_meter("frame_editor/mix_percent", dx, dy, dw, floor(tl_edit.value[e_value.MIX_PERCENT] * 100), 0, 100, 0, 1, mixtbx, action_tl_frame_mix_percent)
			tab_next()
		}
		
		if (setting_advanced_mode)
			tab_collapse_end()
	}
	
	#endregion
	
	context_menu_group_temp = null
}
