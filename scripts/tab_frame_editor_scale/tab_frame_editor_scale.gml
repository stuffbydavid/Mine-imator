/// tab_frame_editor_scale()

function tab_frame_editor_scale()
{
	if (!tl_edit.value_type[e_value_type.TRANSFORM_SCA])
		return 0
	
	context_menu_group_temp = e_context_group.SCALE
	tab_frame_editor_buttons()
	draw_label(text_get("frameeditorscale"), dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	dy += 26
	
	var snapval, script;
	snapval = (dragger_snap ? setting_snap_size_scale : snap_min);
	script = (tab.transform.scale_all ? action_tl_frame_scale_all_axis : action_tl_frame_scale)
	
	textfield_group_add("frameeditorscalex", tl_edit.value[e_value.SCA_X], 1, script, X, tab.transform.tbx_sca_x, null, max(0.0001, tl_edit.value[e_value.SCA_X] / 50))
	
	axis_edit = (setting_z_is_up ? Y : Z)
	textfield_group_add("frameeditorscaley", tl_edit.value[e_value.SCA_X + axis_edit], 1, script, axis_edit, tab.transform.tbx_sca_y, null, max(0.0001, tl_edit.value[e_value.SCA_X + axis_edit] / 50))
	
	axis_edit = (setting_z_is_up ? Z : Y)
	textfield_group_add("frameeditorscalez", tl_edit.value[e_value.SCA_X + axis_edit], 1, script, axis_edit, tab.transform.tbx_sca_z, null, max(0.0001, tl_edit.value[e_value.SCA_X + axis_edit] / 50))
		
	tab_control_textfield_group(false)
	draw_textfield_group("frameeditorscale", dx, dy, dw, 0.1, snap_min, no_limit, snapval, false, true, true)
	tab_next()
	
	context_menu_group_temp = null
}
