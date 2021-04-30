/// action_tl_frame_roughness(value, add)
/// @arg value
/// @arg add

function action_tl_frame_roughness(val, add)
{
	tl_value_set_start(action_tl_frame_roughness, true)
	tl_value_set(e_value.ROUGHNESS, val / 100, add)
	tl_value_set_done()
}
