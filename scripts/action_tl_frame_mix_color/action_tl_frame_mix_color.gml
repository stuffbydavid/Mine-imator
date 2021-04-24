/// action_tl_frame_mix_color(color)
/// @arg color

function action_tl_frame_mix_color(color)
{
	tl_value_set_start(action_tl_frame_mix_color, true)
	tl_value_set(e_value.MIX_COLOR, color, false)
	tl_value_set_done()
}
