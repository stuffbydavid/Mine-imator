/// action_background_ground_slot(slot)
/// @arg slot

var slot;

if (history_undo)
	slot = history_data.oldval
else if (history_redo)
	slot = history_data.newval
else
{
	slot = argument0
	history_set_var(action_background_ground_slot, background_ground_slot, slot, false)
}

background_ground_slot = slot
background_ground_update_texture()
