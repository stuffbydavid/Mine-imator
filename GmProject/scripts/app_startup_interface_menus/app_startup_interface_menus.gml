/// app_startup_interface_menus()

function app_startup_interface_menus()
{
	menu_list = ds_list_create()
	menu_count = 0
	menu_current = 0
	menu_popup = null
	menu_scroll = false
	menu_filter = ""
	menu_filter_normal = ""
	
	menu_model_current = null
	menu_model_state = null
	menu_model_state_current = null
	menu_block_current = null
	menu_block_state = null
	menu_block_state_current = null
	menu_bench = false
	
	menu_armor_piece = 0
	menu_armor_piece_data = 0
}
