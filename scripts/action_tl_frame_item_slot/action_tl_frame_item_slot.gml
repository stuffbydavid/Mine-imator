/// action_tl_frame_item_slot(slot, [add])
/// @arg slot
/// @arg [add]

var add = false;

if (argument_count > 1)
	add = argument[1]

tl_value_set_start(action_tl_frame_item_slot, true)
tl_value_set(e_value.ITEM_SLOT, argument[0], add)
tl_value_set_done()
