/// action_tl_frame_alpha(value, add)
/// @arg value
/// @arg add

function action_tl_frame_alpha(argument0, argument1)
{
	tl_value_set_start(action_tl_frame_alpha, true)
	tl_value_set(e_value.ALPHA, argument0 / 100, argument1)
	tl_value_set_done()
}
