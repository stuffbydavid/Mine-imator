/// tab_timeline_editor_graphics()
	
if (tl_edit.type != e_tl_type.POINT_LIGHT && tl_edit.type != e_tl_type.SPOT_LIGHT)
{
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
	
	// Wind
	if (tl_edit.type = e_temp_type.SCENERY || tl_edit.type = e_temp_type.BLOCK || tl_edit.type = e_temp_type.PARTICLE_SPAWNER || tl_edit.type = e_temp_type.TEXT || type_is_shape(tl_edit.type))
	{
		tab_control_checkbox()
		draw_checkbox("timelineeditorwind", dx, dy, tl_edit.wind, action_tl_wind)
		if (tl_edit.type != e_temp_type.TEXT && !type_is_shape(tl_edit.type))
			draw_checkbox("timelineeditorwindterrain", dx + floor(dw * 0.5), dy, tl_edit.wind_terrain, action_tl_wind_terrain)
		tab_next()
	}
	
	// Glow
	tab_control_checkbox()
	draw_checkbox("timelineeditorglow", dx, dy, tl_edit.glow, action_tl_glow)
	if (tl_edit.glow)
	{
		draw_checkbox("timelineeditorglowtexture", dx + floor(dw * 0.5), dy, tl_edit.glow_texture, action_tl_glow_texture)
		tab_next()
		draw_checkbox("timelineeditoronlyrenderglow", dx, dy, tl_edit.only_render_glow, action_tl_only_render_glow)
	}
	tab_next()

	// Fog
	tab_control_checkbox()
	draw_checkbox("timelineeditorfog", dx, dy, tl_edit.fog, action_tl_fog)
	tab_next()

	// Depth
	tab_control_dragger()
	draw_dragger("timelineeditordepth", dx, dy, dw, tl_edit.depth, 0.1, -no_limit, no_limit, 0, 1, tab.graphics.tbx_depth, action_tl_depth)
	tab_next()
	
	// Blend mode
	tab_control(24)
	draw_button_menu("timelineeditorblendmode", e_menu.LIST, dx, dy, dw, 24, tl_edit.blend_mode, text_get("timelineeditorblendmode" + tl_edit.blend_mode), action_tl_blend_mode)
	tab_next()
	
	// Backfaces
	tab_control_checkbox()
	draw_checkbox("timelineeditorbackfaces", dx, dy, tl_edit.backfaces, action_tl_backfaces)
	tab_next()
	
	// High quality hiding
	tab_control_checkbox()
	draw_checkbox("timelineeditorhqhiding", dx, dy, tl_edit.hq_hiding, action_tl_hq_hiding)
	
	// Low quality hiding
	draw_checkbox("timelineeditorlqhiding", dx + floor(dw * 0.5), dy, tl_edit.lq_hiding, action_tl_lq_hiding)
	tab_next()
	
	// Foliage tint
	tab_control_checkbox()
	draw_checkbox("timelineeditorfoliagetint", dx, dy, tl_edit.foliage_tint, action_tl_foliage_tint)
	
	// Bleed light
	tab_control_checkbox()
	draw_checkbox("timelineeditorbleedlight", dx + floor(dw * 0.5), dy, tl_edit.bleed_light, action_tl_bleed_light)
	tab_next()
}
else
{
	// Shadows
	tab_control_checkbox()
	draw_checkbox("timelineeditorrendershadows", dx, dy, tl_edit.shadows, action_tl_shadows)
	tab_next()
}