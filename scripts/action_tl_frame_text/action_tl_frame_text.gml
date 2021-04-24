/// action_tl_frame_text(text)
/// @arg text

function action_tl_frame_text(text)
{
	tl_value_set_start(action_tl_frame_text, true)
	tl_value_set(e_value.TEXT, text, false)
	tl_value_set_done()
}
