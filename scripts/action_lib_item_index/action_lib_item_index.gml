/// action_lib_item_index(index)
/// @arg index

var index;

if (history_undo)
	index = history_data.oldval
else if (history_redo)
	index = history_data.newval
else
{
	index = argument0
	history_set_var(action_lib_item_index, temp_edit.item_index, index, false)
}

with (temp_edit)
{
	item_index = index
	temp_update_item()
}

lib_preview.update = true
