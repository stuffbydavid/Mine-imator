/// action_lib_pc_spawn_region_use(use)
/// @arg use

var use;

if (history_undo)
	use = history_data.old_value
else if (history_redo)
	use = history_data.new_value
else
{
	use = argument0
	history_set_var(action_lib_pc_spawn_region_use, temp_edit.pc_spawn_region_use, use, false)
}
	
temp_edit.pc_spawn_region_use = use
