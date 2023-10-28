/// action_tl_frame_text_outline(enable)
/// @arg enable

function action_tl_frame_text_outline(enable)
{
	tl_value_set_start(action_tl_frame_text_outline, false)
	tl_value_set(e_value.TEXT_OUTLINE, enable, false)
	tl_value_set_done()
}
