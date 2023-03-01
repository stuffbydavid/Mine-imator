/// action_tl_frame_item_slot(slot, [add])
/// @arg slot
/// @arg [add]

function action_tl_frame_item_slot(slot, add)
{
	if (add = undefined)
		add = false
	
	tl_value_set_start(action_tl_frame_item_slot, true)
	tl_value_set(e_value.ITEM_SLOT, slot, add)
	tl_value_set_done()
}
