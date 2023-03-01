/// action_tl_frame_hsb_mul(color)
/// @arg color

function action_tl_frame_hsb_mul(color)
{
	tl_value_set_start(action_tl_frame_hsb_mul, true)
	tl_value_set(e_value.HSB_MUL, color, false)
	tl_value_set_done()
}
