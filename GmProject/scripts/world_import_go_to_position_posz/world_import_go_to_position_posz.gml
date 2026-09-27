/// world_import_go_to_position_posz(val, add)

function world_import_go_to_position_posz(val, add)
{
	world_import_settings_gotoposition_z = val + (add ? world_import_settings_gotoposition_z : 0)
}