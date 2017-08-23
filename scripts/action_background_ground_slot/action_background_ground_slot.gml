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
	history_set_var(action_background_ground_slot, background_ground_slot, slot, false)
}

background_ground_slot = slot
background_ground_update_texture()
