function action_tl_frame_visible(enabled)
{
	tl_value_set_start(action_tl_frame_visible, false)
	tl_value_set(e_value.VISIBLE, enabled, false)
	tl_value_set_done()
}
