/// tab_frame_editor_material()

function tab_frame_editor_material()
{
	// Texture
	tab_frame_editor_texture()
	
	// Opacity
	tab_control_meter()
	draw_meter("frameeditoropacity", dx, dy, dw, round(tl_edit.value[e_value.ALPHA] * 100), 56, 0, 100, 100, 1, tab.material.tbx_alpha, action_tl_frame_alpha)
	tab_next()
	
	// Color properties
	if (tl_edit.value_type[e_value_type.MATERIAL_COLOR])
		tab_frame_editor_color()
	
	// Surface properties
	if (tl_edit.value_type[e_value_type.MATERIAL_SURFACE])
	{
		tab_control_switch()
		draw_button_collapse("material_surface", collapse_map[?"material_surface"], null, true, "frameeditorsurface")
		tab_next()
	
		if (collapse_map[?"material_surface"])
		{
			tab_collapse_start()
		
			// Material texture
			tab_frame_editor_texture_material()
		
			// Normal texture
			if (project_render_material_maps)
				tab_frame_editor_tex_normal()
		
			tab_collapse_end()
		}
	}
	
	// Subsurface properties
	if (tl_edit.value_type[e_value_type.MATERIAL_SUBSURFACE])
	{
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
	}
	
	// Wind influence
	if (type_has_wind(tl_edit.type) && (tl_edit.wind || tl_edit.wind_terrain))
	{
		tab_control_meter()
		draw_meter("frameeditorwindinfluence", dx, dy, dw, round(tl_edit.value[e_value.WIND_INFLUENCE] * 100), 56, 0, 100, 100, 1, tab.material.tbx_wind_influence, action_tl_frame_wind_influence)
		tab_next()
	}
}
