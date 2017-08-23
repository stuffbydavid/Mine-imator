/// action_lib_pc_type_spawn_region(region)
/// @arg region

var region;

if (history_undo)
	region = history_data.old_value
else if (history_redo)
	region = history_data.new_value
else
{
	region = argument0
	history_set_var(action_lib_pc_type_spawn_region, ptype_edit.spawn_region, region, false)
}

ptype_edit.spawn_region = region
