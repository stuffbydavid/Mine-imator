/// action_tl_frame_path_offset(value, add)
/// @arg value
/// @arg add

function action_tl_frame_path_offset(val, add)
{
	tl_value_set_start(action_tl_frame_path_offset, true)
	tl_value_set(e_value.PATH_OFFSET, val, add)
	tl_value_set_done()
}
