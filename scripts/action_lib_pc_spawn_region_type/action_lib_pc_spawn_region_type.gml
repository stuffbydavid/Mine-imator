/// action_lib_pc_spawn_region_type(type)
/// @arg type

var type;

if (history_undo)
	type = history_data.old_value
else if (history_redo)
	type = history_data.new_value
else
{
	type = argument0
	history_set_var(action_lib_pc_spawn_region_type, temp_edit.pc_spawn_region_type, type, false)
}

temp_edit.pc_spawn_region_type = type
