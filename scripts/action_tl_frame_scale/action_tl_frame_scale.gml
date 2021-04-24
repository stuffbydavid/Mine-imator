/// action_tl_frame_scale(value, add)
/// @arg value
/// @arg add

function action_tl_frame_scale(val, add)
{
	tl_value_set_start(action_tl_frame_scale, true)
	tl_value_set(e_value.SCA_X + axis_edit, val, add)
	tl_value_set_done()
}
