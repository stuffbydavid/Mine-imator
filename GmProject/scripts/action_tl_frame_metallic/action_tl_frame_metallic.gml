/// action_tl_frame_metallic(value, add)
/// @arg value
/// @arg add

function action_tl_frame_metallic(val, add)
{
	tl_value_set_start(action_tl_frame_metallic, true)
	tl_value_set(e_value.METALLIC, val / 100, add)
	tl_value_set_done()
}