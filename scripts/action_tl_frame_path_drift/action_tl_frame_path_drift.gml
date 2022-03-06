/// action_tl_frame_path_drift(value, add)
/// @arg value
/// @arg add

function action_tl_frame_path_drift(val, add)
{
	tl_value_set_start(action_tl_frame_path_drift, true)
	tl_value_set(e_value.PATH_DRIFT, val, add)
	tl_value_set_done()
}
