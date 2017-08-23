/// action_lib_item_slot(slot)
/// @arg slot

var slot;

if (history_undo)
	slot = history_data.old_value
else if (history_redo)
	slot = history_data.new_value
else
{
	slot = argument0
	history_set_var(action_lib_item_slot, temp_edit.item_slot, slot, false)
}

with (temp_edit)
{
	item_slot = slot
	temp_update_item()
}

lib_preview.update = true
