/// tab_frame_editor_scale()

var snapval = (dragger_snap ? setting_snap_size_scale : snap_min);

context_menu_group_temp = e_context_group.SCALE

if (tab.scale.scale_all) // Simple scaling
{
	tab_control_dragger()
	draw_dragger("frameeditorscalexyz", dx, dy, 86, tl_edit.value[e_value.SCA_X], max(0.0001, tl_edit.value[e_value.SCA_X] / 50), snapval, no_limit, 1, snapval, tab.scale.tbx_x, action_tl_frame_scale_all)
	tab_next()
}
else
{
	tab_control(28)
	textfield_group_add("frameeditorscalex", tl_edit.value[e_value.SCA_X], 1, action_tl_frame_scale, X, tab.scale.tbx_x, null, max(0.0001, tl_edit.value[e_value.SCA_X] / 50))

	axis_edit = (setting_z_is_up ? Y : Z)
	textfield_group_add("frameeditorscaley", tl_edit.value[e_value.SCA_X + axis_edit], 1, action_tl_frame_scale, axis_edit, tab.scale.tbx_y, null, max(0.0001, tl_edit.value[e_value.SCA_X + axis_edit] / 50))

	axis_edit = (setting_z_is_up ? Z : Y)
	textfield_group_add("frameeditorscalez", tl_edit.value[e_value.SCA_X + axis_edit], 1, action_tl_frame_scale, axis_edit, tab.scale.tbx_z, null, max(0.0001, tl_edit.value[e_value.SCA_X + axis_edit] / 50))
	
	draw_textfield_group("frameeditorscale", dx, dy, dw, 0.1, snap_min, no_limit, snapval)
	tab_next()
}
context_menu_group_temp = null
