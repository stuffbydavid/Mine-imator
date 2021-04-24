/// action_tl_frame_scale_all(value, add)
/// @arg value
/// @arg add

function action_tl_frame_scale_all(val, add)
{
	tl_value_set_start(action_tl_frame_scale_all, true)
	tl_value_set(e_value.SCA_X, val, add)
	tl_value_set(e_value.SCA_Y, val, add)
	tl_value_set(e_value.SCA_Z, val, add)
	tl_value_set_done()
}
