/// action_tl_frame_light_color(color)
/// @arg color

function action_tl_frame_light_color(color)
{
	tl_value_set_start(action_tl_frame_light_color, true)
	tl_value_set(e_value.LIGHT_COLOR, color, false)
	tl_value_set_done()
}
