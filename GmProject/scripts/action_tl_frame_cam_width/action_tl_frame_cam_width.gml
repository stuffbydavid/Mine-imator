/// action_tl_frame_cam_width(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_width(val, add)
{
	var ratio = tl_edit.value[e_value.CAM_WIDTH] / tl_edit.value[e_value.CAM_HEIGHT];
	
	tl_value_set_start(action_tl_frame_cam_width, true)
	tl_value_set(e_value.CAM_WIDTH, val, add)
	if (tl_edit.value[e_value.CAM_SIZE_KEEP_ASPECT_RATIO])
		tl_value_set(e_value.CAM_HEIGHT, max(1, round(tl_edit.value[e_value.CAM_WIDTH] / ratio)), false)
	tl_value_set_done()
}
