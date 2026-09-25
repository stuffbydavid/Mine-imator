/// action_tl_frame_text_custom_alignment(enable)

function action_tl_frame_text_custom_alignment(enable)
{
	tl_value_set_start(action_tl_frame_text_custom_alignment, false)
	tl_value_set(e_value.TEXT_CUSTOM_ALIGNMENT, enable, false)
	tl_value_set_done()
}
