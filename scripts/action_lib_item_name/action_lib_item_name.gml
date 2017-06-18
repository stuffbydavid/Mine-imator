/// action_lib_item_name(name)
/// @arg name

var name;

if (history_undo)
	name = history_data.oldval
else if (history_redo)
	name = history_data.newval
else
{
	name = argument0
	history_set_var(action_lib_item_name, temp_edit.item_name, name, false)
}

with (temp_edit)
{
	item_name = name
	temp_update_item()
}

lib_preview.update = true
