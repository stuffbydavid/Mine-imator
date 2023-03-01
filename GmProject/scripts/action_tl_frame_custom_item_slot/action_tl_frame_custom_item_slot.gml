/// action_tl_frame_custom_item_slot(custom)
/// @arg custom

function action_tl_frame_custom_item_slot(custom)
{
	tl_value_set_start(action_tl_frame_custom_item_slot, false)
	tl_value_set(e_value.CUSTOM_ITEM_SLOT, custom, false)
	tl_value_set_done()
}
