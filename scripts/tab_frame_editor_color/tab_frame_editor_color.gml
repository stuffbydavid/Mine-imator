/// tab_frame_editor_color()

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
	draw_button_color("frameeditorrgbmul", dx, dy, dw, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul, tab.material.tbx_rgb_mul)
	tab_next()
	
	tab_control_color()
	draw_button_color("frameeditorhsvmul", dx, dy, dw, tl_edit.value[e_value.HSB_MUL], c_white, true, action_tl_frame_hsb_mul, tab.material.tbx_hsv_mul)
	tab_next()
	
	// Add
	tab_control_color()
	draw_button_color("frameeditorrgbadd", dx, dy, dw, tl_edit.value[e_value.RGB_ADD], c_black, false, action_tl_frame_rgb_add, tab.material.tbx_rgb_add)
	tab_next()
	
	tab_control_color()
	draw_button_color("frameeditorhsvadd", dx, dy, dw, tl_edit.value[e_value.HSB_ADD], c_black, true, action_tl_frame_hsb_add, tab.material.tbx_hsv_add)
	tab_next()
	
	// Sub
	tab_control_color()
	draw_button_color("frameeditorrgbsub", dx, dy, dw, tl_edit.value[e_value.RGB_SUB], c_black, false, action_tl_frame_rgb_sub, tab.material.tbx_rgb_sub)
	tab_next()
	
	tab_control_color()
	draw_button_color("frameeditorhsvsub", dx, dy, dw, tl_edit.value[e_value.HSB_SUB], c_black, true, action_tl_frame_hsb_sub, tab.material.tbx_hsv_sub)
	tab_next()
}
else
{
	// Blend color
	tab_control_color()
	draw_button_color("frameeditorblendcolor", dx, dy, dw, tl_edit.value[e_value.RGB_MUL], c_white, false, action_tl_frame_rgb_mul, tab.material.tbx_rgb_mul)
	tab_next()
}

// Mix and glow color
var glowenabled = tl_edit.glow && !tl_edit.value_type[e_value_type.CAMERA];

tab_control_color()
draw_button_color("frameeditormixcolor", dx, dy, dw, tl_edit.value[e_value.MIX_COLOR], c_black, false, action_tl_frame_mix_color, tab.material.tbx_color_mix)
tab_next()

if (glowenabled)
{
	tab_control_color()
	draw_button_color("frameeditorglowcolor", dx, dy, dw, tl_edit.value[e_value.GLOW_COLOR], c_white, false, action_tl_frame_glow_color, tab.material.tbx_color_glow)
	tab_next()
}	

tab_set_collumns(false)

tab_control_meter()
draw_meter("frameeditormixpercent", dx, dy, dw, floor(tl_edit.value[e_value.MIX_PERCENT] * 100), 60, 0, 100, 0, 1, tab.material.tbx_mix_percent, action_tl_frame_mix_percent)
tab_next()

// Brightness
tab_control_meter()
draw_meter("frameeditoremission", dx, dy, dw, round(tl_edit.value[e_value.BRIGHTNESS] * 100), 60, 0, 100, 0, 1, tab.material.tbx_brightness, action_tl_frame_brightness)
tab_next()

context_menu_group_temp = null
