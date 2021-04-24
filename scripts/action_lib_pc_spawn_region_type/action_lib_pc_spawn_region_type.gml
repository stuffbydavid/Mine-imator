/// action_lib_pc_spawn_region_type(type)
/// @arg type

function action_lib_pc_spawn_region_type(type)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_region_type, temp_edit.pc_spawn_region_type, type, false)
	
	temp_edit.pc_spawn_region_type = type
}
