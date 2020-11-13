/// app_startup_micro_animations()
/// @desc Sets up micro animations for use with components

globalvar mcroani_arr, current_mcroani;
globalvar microanis, microani_hover, microani_click, microani_value;

mcroani_arr = array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
current_mcroani = null

microanis = ds_map_create()

enum e_mcroani
{
	HOVER,
	RADIO_HOVER,
	PRESS,
	ACTIVE,
	DISABLED,
	CUSTOM,
	HOVER_LINEAR,
	RADIO_HOVER_LINEAR,
	PRESS_LINEAR,
	ACTIVE_LINEAR,
	DISABLED_LINEAR,
	CUSTOM_LINEAR
}

radiobutton_animation_group = null
