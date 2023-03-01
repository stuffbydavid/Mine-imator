/// action_tl_frame_seed(value, add)
/// @arg value
/// @arg add

function action_tl_frame_seed(val, add)
{
	tl_value_set_start(action_tl_frame_seed, true)
	tl_value_set(e_value.SEED, val, add)
	tl_value_set_done()
}
