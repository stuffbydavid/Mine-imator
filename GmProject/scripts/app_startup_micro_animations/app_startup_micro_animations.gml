/// @desc Sets up micro animations for use with components.

function app_startup_micro_animations()
{
	globalvar microani_arr, current_microani, microani_list, microani_delete_list;
	globalvar microanis, microani_hover, microani_click, microani_value, microani_prefix;
	
	microani_arr = array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	current_microani = null
	
	microani_list = ds_list_create()
	microani_delete_list = ds_list_create()
	
	microanis = ds_map_create()
	microani_prefix = ""
}
