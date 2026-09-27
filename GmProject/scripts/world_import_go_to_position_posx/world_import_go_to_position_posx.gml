/// world_import_go_to_position_posx(val, add)

function world_import_go_to_position_posx(val, add)
{
	world_import_settings_gotoposition_x = val + (add ? world_import_settings_gotoposition_x : 0)
}