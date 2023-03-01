/// action_tl_frame_visible(enable)
/// @arg enable

function action_tl_frame_visible(enable)
{
	tl_value_set_start(action_tl_frame_visible, false)
	tl_value_set(e_value.VISIBLE, enable, false)
	tl_value_set_done()
}
