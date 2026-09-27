/// app_startup_micro_animations()
/// @desc Sets up micro animations for use with components

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
	
	enum e_microani
	{
		HOVER,
		RADIO_HOVER,
		PRESS,
		ACTIVE,
		DISABLED,
		CUSTOM,
		FADE,
		HOVER_LINEAR,
		RADIO_HOVER_LINEAR,
		PRESS_LINEAR,
		ACTIVE_LINEAR,
		DISABLED_LINEAR,
		CUSTOM_LINEAR,
		FADE_LINEAR,
		GOAL_EASE
	}
}
