/// action_lib_pc_spawn_region_use(use)
/// @arg use

function action_lib_pc_spawn_region_use(use)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_spawn_region_use, temp_edit.pc_spawn_region_use, use, false)
	
	temp_edit.pc_spawn_region_use = use
}
