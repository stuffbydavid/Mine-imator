/// tab_timeline_editor_graphics()
	
// Round bending
/*if (tl_edit.type = "bodypart")
{
	if (tl_edit.bodypart < tl_edit.temp.char_model.part_amount)
	{
		if (tl_edit.temp.char_model.part_hasbend[tl_edit.bodypart])
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorroundbending", dx, dy, tl_edit.round_bending, action_tl_round_bending)
			tab_next()
		}
	}
}*/

// Texture
tab_control_checkbox()
draw_checkbox("timelineeditortextureblur", dx, dy, tl_edit.texture_blur, action_tl_texture_blur)
draw_checkbox("timelineeditortexturefiltering", dx + floor(dw * 0.5), dy, tl_edit.texture_filtering, action_tl_texture_filtering)
tab_next()

// Shadows
tab_control_checkbox()
draw_checkbox("timelineeditorshadows", dx, dy, tl_edit.shadows, action_tl_shadows)
draw_checkbox("timelineeditorssao", dx + floor(dw * 0.5), dy, tl_edit.ssao, action_tl_ssao)
tab_next()

// Fog
tab_control_checkbox()
draw_checkbox("timelineeditorfog", dx, dy, tl_edit.fog, action_tl_fog)
tab_next()

// Wind
if (tl_edit.type = "scenery" || tl_edit.type = "block" || tl_edit.type = "particles" || tl_edit.type = "text" || type_is_shape(tl_edit.type))
{
	tab_control_checkbox()
	draw_checkbox("timelineeditorwind", dx, dy, tl_edit.wind, action_tl_wind)
	if (tl_edit.type != "text" && !type_is_shape(tl_edit.type))
		draw_checkbox("timelineeditorwindterrain", dx + floor(dw * 0.5), dy, tl_edit.wind_terrain, action_tl_wind_terrain)
	tab_next()
}

// Depth
tab_control_dragger()
draw_dragger("timelineeditordepth", dx, dy, dw, tl_edit.depth, 0.1, -no_limit, no_limit, 0, 1, tab.graphics.tbx_depth, action_tl_depth)
tab_next()

// Backfaces
tab_control_checkbox()
draw_checkbox("timelineeditorbackfaces", dx, dy, tl_edit.backfaces, action_tl_backfaces)
tab_next()
