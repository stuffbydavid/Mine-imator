/// action_tl_frame_light_size(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_size(val, add)
{
	tl_value_set_start(action_tl_frame_light_size, true)
	tl_value_set(e_value.LIGHT_SIZE, val, add)
	tl_value_set_done()
}
