/// action_tl_frame_freeze(freeze)
/// @arg freeze

function action_tl_frame_freeze(freeze)
{
	tl_value_set_start(action_tl_frame_freeze, false)
	tl_value_set(e_value.FREEZE, freeze, false)
	tl_value_set_done()
}
