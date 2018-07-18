/// action_tl_frame_cam_vignette_radius(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_vignette_radius, true)
tl_value_set(e_value.CAM_VIGNETTE_RADIUS, argument0 / 100, argument1)
tl_value_set_done()
