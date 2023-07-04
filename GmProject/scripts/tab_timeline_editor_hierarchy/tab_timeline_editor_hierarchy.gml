/// tab_timeline_editor_hierarchy()

function tab_timeline_editor_hierarchy()
{
	var par = tl_edit.parent;
	
	if (par = timeline_move_obj)
		par = tl_edit.move_parent
	
	if (tl_edit.part_of = null)
	{
		var text;
		
		// Parent
		if (par = app)
			text = text_get("timelinenone")
		else
			text = string_remove_newline(par.display_name)
		
		tab_control_menu()
		draw_button_menu("timelineeditorparent", e_menu.TIMELINE, dx, dy, dw, 24, par, text, action_tl_parent)
		tab_next()
		
		if (!tl_edit.value_type[e_value_type.HIERARCHY])
			return 0
		
		// Lock to bended half
		if (par != app && par.type = e_temp_type.BODYPART && par.model_part != null && par.model_part.bend_part != null)
		{
			var partname = array("right", "left", "front", "back", "upper", "lower");
			tab_control_switch()
			draw_switch("timelineeditorlockbend" + partname[par.model_part.bend_part], dx, dy, tl_edit.lock_bend, action_tl_lock_bend)
			tab_next()
		}
	}
	
	if (par != app)
	{
		dy += 20
		draw_label(text_get("timelineeditorinherit") + ":", dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label) 
		dy += 8
		
		tab_set_collumns(true, floor(content_width/150))
		
		// Position
		tab_control_checkbox()
		draw_checkbox("timelineeditorinheritposition", dx, dy, tl_edit.inherit_position, action_tl_inherit_position)
		tab_next()
		
		// Rotation
		if (tl_edit.value_type[e_value_type.TRANSFORM_ROT])
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritrotation", dx, dy, tl_edit.inherit_rotation, action_tl_inherit_rotation)
			tab_next()
		}
		
		// Rotation point
		if (tl_edit.value_type[e_value_type.ROT_POINT] && setting_advanced_mode)
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritrotpoint", dx, dy, tl_edit.inherit_rot_point, action_tl_inherit_rot_point)
			tab_next()
		}
		
		// Scale
		if (tl_edit.value_type[e_value_type.TRANSFORM_SCA])
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritscale", dx, dy, tl_edit.inherit_scale, action_tl_inherit_scale)
			tab_next()
		}
		
		// Color
		if (tl_edit.value_type[e_value_type.MATERIAL_COLOR])
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritopacity", dx, dy, tl_edit.inherit_alpha, action_tl_inherit_alpha)
			tab_next()
			
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritcolor", dx, dy, tl_edit.inherit_color, action_tl_inherit_color)
			tab_next()
		}
		
		// Visibility
		tab_control_checkbox()
		draw_checkbox("timelineeditorinheritvisibility", dx, dy, tl_edit.inherit_visibility, action_tl_inherit_visibility)
		tab_next()
		
		// Bend (Advanced mode only)
		if (tl_edit.value_type[e_value_type.TRANSFORM_BEND] && setting_advanced_mode)
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritbend", dx, dy, tl_edit.inherit_bend, action_tl_inherit_bend)
			tab_next()
		}
		
		// Texture
		if (tl_edit.value_type[e_value_type.MATERIAL_TEXTURE])
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinherittexture", dx, dy, tl_edit.inherit_texture, action_tl_inherit_texture)
			tab_next()
		}
		
		// Surface (Advanced mode only)
		if (tl_edit.value_type[e_value_type.MATERIAL] && setting_advanced_mode)
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritsurface", dx, dy, tl_edit.inherit_surface, action_tl_inherit_surface)
			tab_next()
		}
		
		// Subsurface (Advanced mode only)
		if (tl_edit.value_type[e_value_type.MATERIAL] && setting_advanced_mode)
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritsubsurface", dx, dy, tl_edit.inherit_subsurface, action_tl_inherit_subsurface)
			tab_next()
		}
		
		// Glow color (Advanced mode only)
		if (tl_edit.value_type[e_value_type.MATERIAL] && !tl_edit.value_type[e_value_type.CAMERA] && setting_advanced_mode)
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritglowcolor", dx, dy, tl_edit.inherit_glow_color, action_tl_inherit_glow_color)
			tab_next()
		}
		
		// Select (Advanced mode only)
		if (setting_advanced_mode)
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritselect", dx, dy, tl_edit.inherit_select, action_tl_inherit_select)
			tab_next()	
		}
		
		// Inherit pos
		if ((tl_edit.type = e_tl_type.CHARACTER || tl_edit.type = e_tl_type.SPECIAL_BLOCK || tl_edit.type = e_tl_type.MODEL) &&
			(par.type = e_tl_type.CHARACTER || par.type = e_tl_type.SPECIAL_BLOCK  || par.type = e_tl_type.MODEL))
		{
			tab_control_checkbox()
			draw_checkbox("timelineeditorinheritpose", dx, dy, tl_edit.inherit_pose, action_tl_inherit_pose, "timelineeditorinheritposehelp")
			tab_next()
		}
			
		tab_set_collumns(false)
		
		// Scale mode
		if (tl_edit.value_type[e_value_type.TRANSFORM_SCA] && tl_edit.inherit_scale && setting_advanced_mode)
		{
			tab_control_togglebutton()
			togglebutton_add("timelineeditorscalemoderesize", null, 1, tl_edit.scale_resize = 1, action_tl_scale_resize)
			togglebutton_add("timelineeditorscalemodestretch", null, 0, tl_edit.scale_resize = 0, action_tl_scale_resize)
			draw_togglebutton("timelineeditorscalemode", dx, dy)
			tab_next()
		}
	}
}
