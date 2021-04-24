/// action_setting_noisy_grass_water(value)
/// @arg value

function action_setting_noisy_grass_water(value)
{
	setting_noisy_grass_water = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
