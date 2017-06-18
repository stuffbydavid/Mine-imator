/// action_lib_name(name)
/// @arg name

var name;

if (history_undo)
	name = history_data.oldval
else if (history_redo)
	name = history_data.newval
else
{
	name = argument0
	history_set_var(action_lib_name, temp_edit.name, name, true)
}

with (temp_edit)
{
	id.name = name
	temp_update_display_name()
}
