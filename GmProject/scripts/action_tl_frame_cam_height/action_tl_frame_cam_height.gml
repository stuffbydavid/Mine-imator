/// action_tl_frame_cam_height(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_height(val, add)
{
	var ratio = tl_edit.value[e_value.CAM_WIDTH] / tl_edit.value[e_value.CAM_HEIGHT];
	
	tl_value_set_start(action_tl_frame_cam_height, true)
	tl_value_set(e_value.CAM_HEIGHT, val, add)
	if (tl_edit.value[e_value.CAM_SIZE_KEEP_ASPECT_RATIO])
		tl_value_set(e_value.CAM_WIDTH, max(1, round(tl_edit.value[e_value.CAM_HEIGHT] * ratio)), false)
	tl_value_set_done()
}
