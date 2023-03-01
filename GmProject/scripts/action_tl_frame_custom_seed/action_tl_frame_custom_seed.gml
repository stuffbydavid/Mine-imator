/// action_tl_frame_custom_seed(customseed)
/// @arg customseed

function action_tl_frame_custom_seed(customseed)
{
	tl_value_set_start(action_tl_frame_custom_seed, false)
	tl_value_set(e_value.CUSTOM_SEED, customseed, false)
	tl_value_set_done()
}
