/// tab_frame_editor_rotation()

var snapval = (dragger_snap ? setting_snap_size_rotation : 0.1);

context_menu_group_temp = e_context_group.ROTATION

tab_control(60)
axis_edit = X
draw_wheel("frameeditorrotationx", floor(dx + dw/6), dy + 24, c_axisred, tl_edit.value[e_value.ROT_X], -no_limit, no_limit, tl_edit.value_default[e_value.ROT_X], snapval, tab.rotation.loops, tab.rotation.tbx_x, action_tl_frame_rot)

axis_edit = (setting_z_is_up ? Y : Z)
draw_wheel("frameeditorrotationy", floor(dx + dw/2), dy + 24, c_axisgreen, tl_edit.value[e_value.ROT_X + axis_edit], -no_limit, no_limit, tl_edit.value_default[e_value.ROT_X + axis_edit], snapval, tab.rotation.loops, tab.rotation.tbx_y, action_tl_frame_rot)

axis_edit = (setting_z_is_up ? Z : Y)
draw_wheel("frameeditorrotationz", floor(dx + dw - dw/6), dy + 24, c_axisblue, tl_edit.value[e_value.ROT_X + axis_edit], -no_limit, no_limit, tl_edit.value_default[e_value.ROT_X + axis_edit], snapval, tab.rotation.loops, tab.rotation.tbx_z, action_tl_frame_rot)
tab_next()

context_menu_group_temp = null
