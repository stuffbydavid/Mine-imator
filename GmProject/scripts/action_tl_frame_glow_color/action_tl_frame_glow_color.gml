/// action_tl_frame_glow_color(color)
/// @arg color

function action_tl_frame_glow_color(color)
{
	tl_value_set_start(action_tl_frame_glow_color, true)
	tl_value_set(e_value.GLOW_COLOR, color, false)
	tl_value_set_done()
}
