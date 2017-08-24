/// tab_frame_editor_light()

var capwid = text_caption_width("frameeditorlightrange", "frameeditorlightfadesize", "frameeditorlightspotradius", "frameeditorlightspotsharpness")

tab_control_color()
draw_button_color("frameeditorlightcolor", dx, dy, dw, tl_edit.value[e_value.LIGHT_COLOR], c_white, false, action_tl_frame_light_color)
tab_next()

tab_control_dragger()
draw_dragger("frameeditorlightrange", dx, dy, dw, tl_edit.value[e_value.LIGHT_RANGE], tl_edit.value[e_value.LIGHT_RANGE] / 100, 0, no_limit, 250, 0, tab.light.tbx_range, action_tl_frame_light_range, capwid)
tab_next()

tab_control_meter()
draw_meter("frameeditorlightfadesize", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_FADE_SIZE] * 100), 56, 0, 100, 50, 1, tab.light.tbx_fade_size, action_tl_frame_light_fade_size, capwid)
tab_next()

if (tab.light.has_spotlight)
{
	tab_control_meter()
	draw_meter("frameeditorlightspotradius", dx, dy, dw, tl_edit.value[e_value.LIGHT_SPOT_RADIUS], 56, 1, 150, 50, 1, tab.light.tbx_spot_radius, action_tl_frame_light_spot_radius, capwid)
	tab_next()
	
	tab_control_meter()
	draw_meter("frameeditorlightspotsharpness", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_SPOT_SHARPNESS] * 100), 56, 0, 100, 50, 1, tab.light.tbx_spot_sharpness, action_tl_frame_light_spot_sharpness, capwid)
	tab_next()
}

// Tools
tab_control(24)

if (draw_button_normal("frameeditorlightreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.RESET))
	action_tl_frame_set_light(c_white, 250, 0.5, 50, 0.5)
	
if (draw_button_normal("frameeditorlightcopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.COPY))
{
	tab.light.copy_color = tl_edit.value[e_value.LIGHT_COLOR]
	tab.light.copy_range = tl_edit.value[e_value.LIGHT_RANGE]
	tab.light.copy_fade_size = tl_edit.value[e_value.LIGHT_FADE_SIZE]
	tab.light.copy_spot_radius = tl_edit.value[e_value.LIGHT_SPOT_RADIUS]
	tab.light.copy_spot_sharpness = tl_edit.value[e_value.LIGHT_SPOT_SHARPNESS]
}

if (draw_button_normal("frameeditorlightpaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.PASTE))
{
	action_tl_frame_set_light(tab.light.copy_color, 
							  tab.light.copy_range, 
							  tab.light.copy_fade_size, 
							  tab.light.copy_spot_radius, 
							  tab.light.copy_spot_sharpness)
}
tab_next()
