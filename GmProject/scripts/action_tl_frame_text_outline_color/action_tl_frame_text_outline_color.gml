/// action_tl_frame_text_outline_color(color)
/// @arg color

function action_tl_frame_text_outline_color(color)
{
	tl_value_set_start(action_tl_frame_text_outline_color, true)
	tl_value_set(e_value.TEXT_OUTLINE_COLOR, color, false)
	tl_value_set_done()
}
