/// action_tl_frame_cam_width(value, add)
/// @arg value
/// @arg add

var ratio = tl_edit.value[e_value.CAM_WIDTH] / tl_edit.value[e_value.CAM_HEIGHT];

tl_value_set_start(action_tl_frame_camwidth, true)
tl_value_set(e_value.CAM_WIDTH, argument0, argument1)
if (tl_edit.value[e_value.CAM_SIZE_KEEP_ASPECT_RATIO])
	tl_value_set(e_value.CAM_HEIGHT, max(1, round(tl_edit.value[e_value.CAM_WIDTH] / ratio)), false)
tl_value_set_done()
