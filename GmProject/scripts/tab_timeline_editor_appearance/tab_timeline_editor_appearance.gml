/// tab_timeline_editor_appearance()

function tab_timeline_editor_appearance()
{
	if (tl_edit.type != e_tl_type.POINT_LIGHT && tl_edit.type != e_tl_type.SPOT_LIGHT)
	{
		// Blend mode
		tab_control_menu()
		draw_button_menu("timelineeditorblendmode", e_menu.LIST, dx, dy, dw, 24, tl_edit.blend_mode, text_get("timelineeditorblendmode" + tl_edit.blend_mode), action_tl_blend_mode)
		tab_next()
		
		// Alpha mode
		var text;
		if (tl_edit.alpha_mode = e_alpha_mode.BLEND)
			text = text_get("renderalphamodeblend")
		else if (tl_edit.alpha_mode = e_alpha_mode.HASHED)
			text = text_get("renderalphamodehashed")
		else
			text = text_get("renderalphamodedefault")
			
		tab_control_menu()
		draw_button_menu("timelineeditoralphamode", e_menu.LIST, dx, dy, dw, 24, tl_edit.alpha_mode, text, action_tl_alpha_mode)
		tab_next()
		
		// Depth
		tab_control_dragger()
		draw_dragger("timelineeditordepth", dx, dy, dragger_width, tl_edit.depth, 0.1, -no_limit, no_limit, 0, 1, tab.appearance.tbx_depth, action_tl_depth)
		tab_next()
		
		tab_set_collumns(true, floor(content_width/150))
		
		// Texture
		tab_control_checkbox()
		draw_checkbox("timelineeditortextureblur", dx, dy, tl_edit.texture_blur, action_tl_texture_blur)
		tab_next()
		
		tab_control_checkbox()
		draw_checkbox("timelineeditortexturefiltering", dx, dy, tl_edit.texture_filtering, action_tl_texture_filtering)
		tab_next()
		
		// Shadows
		tab_control_checkbox()
		draw_checkbox("timelineeditorshadows", dx, dy, tl_edit.shadows, action_tl_shadows)
		tab_next()
		
		tab_control_checkbox()
		draw_checkbox("timelineeditorssao", dx, dy, tl_edit.ssao, action_tl_ssao)
		tab_next()
		
		// Wind
		if (type_has_wind(tl_edit.type))
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorwind", dx, dy, tl_edit.wind, action_tl_wind)
			tab_next()
			
			if (tl_edit.type != e_temp_type.TEXT && !type_is_shape(tl_edit.type))
			{
				tab_control_checkbox()
				draw_checkbox("timelineeditorwindterrain", dx, dy, tl_edit.wind_terrain, action_tl_wind_terrain)
				tab_next()
			}
		}
		
		// Glow
		tab_control_checkbox()
		draw_checkbox("timelineeditorglow", dx, dy, tl_edit.glow, action_tl_glow)
		tab_next()
		
		if (tl_edit.glow)
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorglowtexture", dx, dy, tl_edit.glow_texture, action_tl_glow_texture)
			tab_next()
			
			tab_control_checkbox()
			draw_checkbox("timelineeditoronlyrenderglow", dx, dy, tl_edit.only_render_glow, action_tl_only_render_glow)
			tab_next()
		}
		
		// Fog
		tab_control_checkbox()
		draw_checkbox("timelineeditorfog", dx, dy, tl_edit.fog, action_tl_fog)
		tab_next()
		
		// Backfaces
		tab_control_checkbox()
		draw_checkbox("timelineeditorbackfaces", dx, dy, tl_edit.backfaces, action_tl_backfaces)
		tab_next()
		
		// High quality hiding
		tab_control_checkbox()
		draw_checkbox("timelineeditorhqhiding", dx, dy, tl_edit.hq_hiding, action_tl_hq_hiding)
		tab_next()
		
		// Low quality hiding
		tab_control_checkbox()
		draw_checkbox("timelineeditorlqhiding", dx, dy, tl_edit.lq_hiding, action_tl_lq_hiding)
		tab_next()
		
		tab_set_collumns(false)
	}
	else
	{
		// Shadows
		tab_control_checkbox()
		draw_checkbox("timelineeditorrendershadows", dx, dy, tl_edit.shadows, action_tl_shadows)
		tab_next()
	}
}
