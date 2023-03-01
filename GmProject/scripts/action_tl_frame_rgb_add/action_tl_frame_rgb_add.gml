/// action_tl_frame_rgb_add(color)
/// @arg color

function action_tl_frame_rgb_add(color)
{
	tl_value_set_start(action_tl_frame_rgb_add, true)
	tl_value_set(e_value.RGB_ADD, color, false)
	tl_value_set_done()
}
