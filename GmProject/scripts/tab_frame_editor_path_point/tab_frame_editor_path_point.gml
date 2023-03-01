/// tab_frame_editor_path_point()

function tab_frame_editor_path_point()
{
	if (!tl_edit.value_type[e_value_type.TRANSFORM_PATH_POINT])
		return 0
	
	var snapval = (dragger_snap ? setting_snap_size_rotation : 0.1);
	
	tab_control_dragger()
	draw_dragger("frameeditorpathpointangle", dx, dy, dragger_width, tl_edit.value[e_value.PATH_POINT_ANGLE], .1, -no_limit, no_limit, 0, snapval, tab.transform.tbx_path_point_angle, action_tl_frame_path_point_angle)
	tab_next()
	
	snapval = (dragger_snap ? setting_snap_size_scale : snap_min)
	
	tab_control_dragger()
	draw_dragger("frameeditorpathpointscale", dx, dy, dragger_width, tl_edit.value[e_value.PATH_POINT_SCALE], .1, 0, no_limit, 1, snapval, tab.transform.tbx_path_point_scale, action_tl_frame_path_point_scale)
	tab_next()
}
