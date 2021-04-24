/// action_tl_frame_cam_rotate_angle_z(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_rotate_angle_z(val, add)
{
	tl_value_set_start(action_tl_frame_cam_rotate_angle_z, true)
	tl_value_set(e_value.CAM_ROTATE_ANGLE_Z, val, add)
	
	if (frame_editor.camera.look_at_rotate)
		tl_value_set(e_value.ROT_X, tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], false)
	
	tl_value_set_done()
}
