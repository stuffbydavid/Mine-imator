/// action_setting_remove_waterlogged_water(value)
/// @arg value

function action_setting_remove_waterlogged_water(value)
{
	setting_remove_waterlogged_water = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
