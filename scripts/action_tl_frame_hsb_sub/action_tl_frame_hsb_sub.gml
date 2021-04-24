/// action_tl_frame_hsb_sub(color)
/// @arg color

function action_tl_frame_hsb_sub(color)
{
	tl_value_set_start(action_tl_frame_hsb_sub, true)
	tl_value_set(e_value.HSB_SUB, color, false)
	tl_value_set_done()
}
