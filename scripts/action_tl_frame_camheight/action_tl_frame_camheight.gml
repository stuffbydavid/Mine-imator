/// action_tl_frame_camheight(value, add)
/// @arg value
/// @arg add

var ratio = tl_edit.value[CAMWIDTH] / tl_edit.value[CAMHEIGHT];

tl_value_set_start(action_tl_frame_camheight, true)
tl_value_set(CAMHEIGHT, argument0, argument1)
if (tl_edit.value[CAMSIZEKEEPASPECTRATIO])
    tl_value_set(CAMWIDTH, max(1, round(tl_edit.value[CAMHEIGHT] * ratio)), false)
tl_value_set_done()
