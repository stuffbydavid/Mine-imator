/// tab_frame_editor_light()

function tab_frame_editor_light()
{
	context_menu_group_temp = e_context_group.LIGHT
	
	tab_control_color()
	draw_button_color("frameeditorlightcolor", dx, dy, dw, tl_edit.value[e_value.LIGHT_COLOR], c_white, false, action_tl_frame_light_color)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorlightsize", dx, dy, dragger_width, tl_edit.value[e_value.LIGHT_SIZE], .05, 0, no_limit, 2, .05, tab.light.tbx_size, action_tl_frame_light_size)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorlightrange", dx, dy, dragger_width, tl_edit.value[e_value.LIGHT_RANGE], tl_edit.value[e_value.LIGHT_RANGE] / 100, 0, no_limit, 250, 0, tab.light.tbx_range, action_tl_frame_light_range)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorlightstrength", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_STRENGTH] * 100), 56, 0, 100, 100, 1, tab.light.tbx_strength, action_tl_frame_light_strength)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorlightspecularstrength", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_SPECULAR_STRENGTH] * 100), 56, 0, 100, 100, 1, tab.light.tbx_specular_strength, action_tl_frame_light_specular_strength)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorlightfadesize", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_FADE_SIZE] * 100), 56, 0, 100, 50, 1, tab.light.tbx_fade_size, action_tl_frame_light_fade_size)
	tab_next()
	
	if (tab.light.has_spotlight)
	{
		tab_control_meter()
		draw_meter("frameeditorlightspotradius", dx, dy, dw, tl_edit.value[e_value.LIGHT_SPOT_RADIUS], 56, 1, 150, 50, 1, tab.light.tbx_spot_radius, action_tl_frame_light_spot_radius)
		tab_next()
		
		tab_control_meter()
		draw_meter("frameeditorlightspotsharpness", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_SPOT_SHARPNESS] * 100), 56, 0, 100, 50, 1, tab.light.tbx_spot_sharpness, action_tl_frame_light_spot_sharpness)
		tab_next()
	}
	
	context_menu_group_temp = null
}
