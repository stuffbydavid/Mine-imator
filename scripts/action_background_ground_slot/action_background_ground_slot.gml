/// action_background_ground_slot(slot)
/// @arg slot

var slot;

if (history_undo)
	slot = history_data.old_value
else if (history_redo)
	slot = history_data.new_value
else
{
	slot = argument0
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_ground_slot, true)
		tl_value_set(e_value.BG_GROUND_SLOT, slot, false)
		tl_value_set_done()
		return 0
	}
	
	history_set_var(action_background_ground_slot, background_ground_slot, slot, true)
}

background_ground_slot = slot
background_ground_update_texture()
