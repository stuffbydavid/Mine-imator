/// action_lib_pc_type_name(name)
/// @arg name

var name;

if (history_undo)
	name = history_data.oldval
else if (history_redo)
	name = history_data.newval
else
{
	name = argument0
	history_set_var(action_lib_pc_type_name, ptype_edit.name, name, true)
}

ptype_edit.name = name
