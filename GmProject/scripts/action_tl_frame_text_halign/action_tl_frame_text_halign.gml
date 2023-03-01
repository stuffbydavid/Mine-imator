/// action_tl_frame_text_halign(halign)
/// @arg halign

function action_tl_frame_text_halign(halign)
{
	tl_value_set_start(action_tl_frame_text_halign, true)
	tl_value_set(e_value.TEXT_HALIGN, halign, false)
	tl_value_set_done()
}
