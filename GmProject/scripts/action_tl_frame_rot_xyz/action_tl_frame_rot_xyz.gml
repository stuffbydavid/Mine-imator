/// action_tl_frame_rot_xyz(rotation)
/// @arg rotation

function action_tl_frame_rot_xyz(rotation)
{
	tl_value_set_start(action_tl_frame_rot_xyz, false)
	tl_value_set(e_value.ROT_X, rotation[@ X], false)
	tl_value_set(e_value.ROT_Y, rotation[@ Y], false)
	tl_value_set(e_value.ROT_Z, rotation[@ Z], false)
	tl_value_set_done()
}
