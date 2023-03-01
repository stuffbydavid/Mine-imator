/// action_tl_frame_cam_rotate_angle_xy(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_rotate_angle_xy(val, add)
{
	tl_value_set_start(action_tl_frame_cam_rotate_angle_xy, true)
	tl_value_set(e_value.CAM_ROTATE_ANGLE_XY, val, add)
	
	if (frame_editor.camera.look_at_rotate)
		tl_value_set(e_value.ROT_Z, tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], false)
	
	tl_value_set_done()
}
