/// action_tl_frame_text_font(object)
/// @arg object

function action_tl_frame_text_font(object)
{
	tl_value_set_start(action_tl_frame_text_font, false)
	tl_value_set(e_value.TEXT_FONT, object, false)
	tl_value_set_done()
}
