/// action_tl_frame_text_valign(valign)
/// @arg valign

function action_tl_frame_text_valign(valign)
{
	tl_value_set_start(action_tl_frame_text_valign, true)
	tl_value_set(e_value.TEXT_VALIGN, valign, false)
	tl_value_set_done()
}
