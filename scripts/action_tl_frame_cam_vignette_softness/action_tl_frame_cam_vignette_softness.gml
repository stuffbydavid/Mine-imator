/// action_tl_frame_cam_vignette_softness(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_vignette_softness, true)
tl_value_set(e_value.CAM_VIGNETTE_SOFTNESS, argument0 / 100, argument1)
tl_value_set_done()
