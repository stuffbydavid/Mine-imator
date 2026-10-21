/// @desc Initialize world import variables.

function app_startup_interface_world_import()
{ 
	world_import_surface = null
	world_import_filter_active = false
	world_import_add_tl = false
	world_import_temp = null
		
	world_import_settings_go_to_position_x = 0
	world_import_settings_go_to_position_z = 0
	tbx_world_import_go_to_position_x = new_textbox_ninteger()
	tbx_world_import_go_to_position_z = new_textbox_ninteger()
	
	world_import_startup()
}
