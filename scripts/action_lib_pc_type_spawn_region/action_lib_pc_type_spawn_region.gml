/// action_lib_pc_type_spawn_region(region)
/// @arg region

function action_lib_pc_type_spawn_region(region)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_pc_type_spawn_region, ptype_edit.spawn_region, region, false)
	
	ptype_edit.spawn_region = region
}
