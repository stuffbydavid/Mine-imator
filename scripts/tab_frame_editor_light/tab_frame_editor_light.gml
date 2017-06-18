/// tab_frame_editor_light()

var capwid = text_caption_width("frameeditorlightrange", "frameeditorlightfadesize", "frameeditorlightspotradius", "frameeditorlightspotsharpness")

tab_control_color()
draw_button_color("frameeditorlightcolor", dx, dy, dw, tl_edit.value[LIGHTCOLOR], c_white, false, action_tl_frame_lightcolor)
tab_next()

tab_control_dragger()
draw_dragger("frameeditorlightrange", dx, dy, dw, tl_edit.value[LIGHTRANGE], tl_edit.value[LIGHTRANGE] / 100, 0, no_limit, 250, 0, tab.light.tbx_range, action_tl_frame_lightrange, capwid)
tab_next()

tab_control_meter()
draw_meter("frameeditorlightfadesize", dx, dy, dw, floor(tl_edit.value[LIGHTFADESIZE] * 100), 56, 0, 100, 50, 1, tab.light.tbx_fade_size, action_tl_frame_lightfadesize, capwid)
tab_next()

if (tab.light.has_spotlight)
{
    tab_control_meter()
    draw_meter("frameeditorlightspotradius", dx, dy, dw, tl_edit.value[LIGHTSPOTRADIUS], 56, 1, 150, 50, 1, tab.light.tbx_spot_radius, action_tl_frame_lightspotradius, capwid)
    tab_next()
    
    tab_control_meter()
    draw_meter("frameeditorlightspotsharpness", dx, dy, dw, floor(tl_edit.value[LIGHTSPOTSHARPNESS] * 100), 56, 0, 100, 50, 1, tab.light.tbx_spot_sharpness, action_tl_frame_lightspotsharpness, capwid)
    tab_next()
}

// Tools
tab_control(24)

if (draw_button_normal("frameeditorlightreset", dx + 25 * 0, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.reset))
    action_tl_frame_set_light(c_white, 250, 0.5, 50, 0.5)
	
if (draw_button_normal("frameeditorlightcopy", dx + 25 * 1, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.copy))
{
    tab.light.copy_color = tl_edit.value[LIGHTCOLOR]
    tab.light.copy_range = tl_edit.value[LIGHTRANGE]
    tab.light.copy_fadesize = tl_edit.value[LIGHTFADESIZE]
    tab.light.copy_spotradius = tl_edit.value[LIGHTSPOTRADIUS]
    tab.light.copy_spotsharpness = tl_edit.value[LIGHTSPOTSHARPNESS]
}

if (draw_button_normal("frameeditorlightpaste", dx + 25 * 2, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.paste))
{
    action_tl_frame_set_light(tab.light.copy_color, 
                              tab.light.copy_range, 
                              tab.light.copy_fadesize, 
                              tab.light.copy_spotradius, 
                              tab.light.copy_spotsharpness)
}
tab_next()
