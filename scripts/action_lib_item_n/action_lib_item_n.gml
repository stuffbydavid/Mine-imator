/// action_lib_item_n(n)
/// @arg n

var slot;

if (history_undo)
    slot = history_data.oldval
else if (history_redo)
    slot = history_data.newval
else
{
    slot = argument0
    history_set_var(action_lib_item_n, temp_edit.item_n, slot, false)
}

with (temp_edit)
{
    item_n = slot
    temp_update_item()
}

lib_preview.update = true
