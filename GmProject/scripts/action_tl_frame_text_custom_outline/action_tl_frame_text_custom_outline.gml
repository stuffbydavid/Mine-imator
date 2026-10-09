function action_tl_frame_text_custom_outline(enabled)
{
	tl_value_set_start(action_tl_frame_text_custom_outline, false)
	tl_value_set(e_value.TEXT_CUSTOM_OUTLINE, enabled, false)
	tl_value_set_done()
}
