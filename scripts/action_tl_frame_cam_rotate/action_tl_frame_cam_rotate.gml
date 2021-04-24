/// action_tl_frame_cam_rotate(rotate)
/// @arg rotate

function action_tl_frame_cam_rotate(rotate)
{
	tl_value_set_start(action_tl_frame_cam_rotate, false)
	tl_value_set(e_value.CAM_ROTATE, rotate, false)
	
	if (frame_editor.camera.look_at_rotate)
	{
		tl_value_set(e_value.ROT_Z, tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], false)
		tl_value_set(e_value.ROT_X, tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], false)
	}
	
	tl_value_set_done()
}
