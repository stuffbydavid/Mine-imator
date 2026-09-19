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
	draw_meter("frameeditorlightfadesize", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_FADE_SIZE] * 100), 0, 100, 50, 1, tab.light.tbx_fade_size, action_tl_frame_light_fade_size)
	tab_next()
	
	if (tab.light.has_spotlight)
	{
		tab_control_meter()
		draw_meter("frameeditorlightspotradius", dx, dy, dw, tl_edit.value[e_value.LIGHT_SPOT_RADIUS], 1, 150, 50, 1, tab.light.tbx_spot_radius, action_tl_frame_light_spot_radius)
		tab_next()
		
		tab_control_meter()
		draw_meter("frameeditorlightspotsharpness", dx, dy, dw, floor(tl_edit.value[e_value.LIGHT_SPOT_SHARPNESS] * 100), 0, 100, 50, 1, tab.light.tbx_spot_sharpness, action_tl_frame_light_spot_sharpness)
		tab_next()
	}
	
	tab_control_dragger()
	draw_dragger("frameeditorlightstrength", dx, dy, dragger_width, floor(tl_edit.value[e_value.LIGHT_STRENGTH] * 100), 0.1, 0, no_limit, 100, 1, tab.light.tbx_strength, action_tl_frame_light_strength)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("frameeditorlightspecularstrength", dx, dy, dragger_width, floor(tl_edit.value[e_value.LIGHT_SPECULAR_STRENGTH] * 100), 0.1, 0, no_limit, 100, 1, tab.light.tbx_specular_strength, action_tl_frame_light_specular_strength)
	tab_next()
	
    if (tl_edit.type = e_tl_type.SPOT_LIGHT)
	{
		var texobj, tex, text;
		texobj = tl_edit.value[e_value.TEXTURE_OBJ]
		tex = null
			
		if (texobj != null)
			text = texobj.display_name
		else
			text = text_get("listnone")
			
		if (texobj = null)
			text = text_get("listdefault", text)
			
		if (texobj != null && texobj.type != e_tl_type.CAMERA) // Don't preview cameras
			tex = texobj.texture
			
		tab_control_menu(ui_large_height)
		draw_button_menu("frameeditorlightgobotexture", e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TEXTURE_OBJ], text, action_tl_frame_texture_light_gobo, false, tex)
		tab_next()
		
		if (tl_edit.value[e_value.TEXTURE_OBJ] != null)
		{
			tab_control_textfield_group(true)
			textfield_group_add("frameeditorlightgobohoffset", tl_edit.value[e_value.LIGHT_SPOT_GOBO_H_OFFSET], 0, action_tl_frame_light_spot_gobo_hoffset, axis_edit, tab.light.tbx_spot_gobo_offset_x, null, 0.1, -no_limit, no_limit)
			textfield_group_add("frameeditorlightgobovoffset", tl_edit.value[e_value.LIGHT_SPOT_GOBO_V_OFFSET], 0, action_tl_frame_light_spot_gobo_voffset, axis_edit, tab.light.tbx_spot_gobo_offset_y, null, 0.1, -no_limit, no_limit)
			draw_textfield_group("frameeditorlightgobooffset", dx, dy, dw, null, null, null, snap_min, true, 1, 3)
			tab_next()																																   
																																				   
			tab_control_textfield_group(true)																											 
			textfield_group_add("frameeditorlightgobohrepeat", tl_edit.value[e_value.LIGHT_SPOT_GOBO_H_REPEAT], 1, action_tl_frame_light_spot_gobo_hrepeat, axis_edit, tab.light.tbx_spot_gobo_repeat_x, null, 0.1, 0, no_limit)
			textfield_group_add("frameeditorlightgobovrepeat", tl_edit.value[e_value.LIGHT_SPOT_GOBO_V_REPEAT], 1, action_tl_frame_light_spot_gobo_vrepeat, axis_edit, tab.light.tbx_spot_gobo_repeat_y, null, 0.1, 0, no_limit)
			draw_textfield_group("frameeditorlightgoborepeat", dx, dy, dw, null, null, null, snap_min, true, 1, 3)
			tab_next()
			
			tab_control_textfield_group(true)																											 
			textfield_group_add("frameeditorlightgoboscalex", tl_edit.value[e_value.LIGHT_GOBO_SCALE_X], 1, action_tl_frame_light_spot_gobo_xscale, X, tab.light.tbx_spot_gobo_scale_x, null, 0.1, 0, no_limit)
			textfield_group_add("frameeditorlightgoboscaley", tl_edit.value[e_value.LIGHT_GOBO_SCALE_Y], 1, action_tl_frame_light_spot_gobo_yscale, Y, tab.light.tbx_spot_gobo_scale_y, null, 0.1, 0, no_limit)
			draw_textfield_group("frameeditorlightgoboscale", dx, dy, dw, null, null, null, snap_min, true, 1, 3)
			tab_next()
			
		}
	}
	
    
	context_menu_group_temp = null
}
