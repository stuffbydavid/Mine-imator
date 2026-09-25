/// action_tl_frame_text_outline_size(value, add)

function action_tl_frame_text_outline_size(val, add)
{
	tl_value_set_start(action_tl_frame_text_outline_size, true)
	tl_value_set(e_value.TEXT_OUTLINE_SIZE, val, add)
	tl_value_set_done()
}
