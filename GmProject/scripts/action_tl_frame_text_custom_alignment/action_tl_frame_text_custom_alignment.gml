function action_tl_frame_text_custom_alignment(enabled)
{
	tl_value_set_start(action_tl_frame_text_custom_alignment, false)
	tl_value_set(e_value.TEXT_CUSTOM_ALIGNMENT, enabled, false)
	tl_value_set_done()
}
