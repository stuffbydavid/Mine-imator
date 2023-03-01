/// action_tl_frame_emissive(value, add)
/// @arg value
/// @arg add

function action_tl_frame_emissive(val, add)
{
	tl_value_set_start(action_tl_frame_emissive, true)
	tl_value_set(e_value.EMISSIVE, val / 100, add)
	tl_value_set_done()

}
