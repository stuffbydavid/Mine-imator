/// action_tl_frame_rgb_sub(color)
/// @arg color

function action_tl_frame_rgb_sub(color)
{
	tl_value_set_start(action_tl_frame_rgb_sub, true)
	tl_value_set(e_value.RGB_SUB, color, false)
	tl_value_set_done()
}
