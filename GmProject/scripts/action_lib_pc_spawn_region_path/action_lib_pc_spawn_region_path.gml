/// action_lib_pc_spawn_region_path(path)
/// @arg path

function action_lib_pc_spawn_region_path(path)
{
	if (history_undo)
		path = save_id_find(history_data.old_value)
	else if (history_redo)
		path = save_id_find(history_data.new_value)
	else
		history_set_var(action_lib_pc_type_temp, save_id_get(temp_edit.pc_spawn_region_path), save_id_get(path), false)
	
	temp_edit.pc_spawn_region_path = path
}
