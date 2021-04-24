/// action_tl_frame_text_aa(enable)
/// @arg enable

function action_tl_frame_text_aa(enable)
{
	tl_value_set_start(action_tl_frame_text_aa, false)
	tl_value_set(e_value.TEXT_AA, enable, false)
	tl_value_set_done()
}
