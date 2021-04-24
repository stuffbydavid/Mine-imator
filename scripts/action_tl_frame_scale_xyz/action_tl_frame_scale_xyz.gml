/// action_tl_frame_scale_xyz(value)
/// @arg value

function action_tl_frame_scale_xyz(value)
{
	tl_value_set_start(action_tl_frame_scale_xyz, false)
	tl_value_set(e_value.SCA_X, value[@ X], false)
	tl_value_set(e_value.SCA_Y, value[@ Y], false)
	tl_value_set(e_value.SCA_Z, value[@ Z], false)
	tl_value_set_done()
}
