/// action_tl_frame_clear(clear)
/// @arg clear

function action_tl_frame_clear(clear)
{
	tl_value_set_start(action_tl_frame_clear, false)
	tl_value_set(e_value.CLEAR, clear, false)
	tl_value_set_done()
}
