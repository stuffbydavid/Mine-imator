/// action_tl_frame_text_custom_outline(enable)

function action_tl_frame_text_custom_outline(enable)
{
	tl_value_set_start(action_tl_frame_text_custom_outline, false)
	tl_value_set(e_value.TEXT_CUSTOM_OUTLINE, enable, false)
	tl_value_set_done()
}
