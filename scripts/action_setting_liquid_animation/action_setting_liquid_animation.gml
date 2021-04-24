/// action_setting_liquid_animation(value)
/// @arg value

function action_setting_liquid_animation(value)
{
	setting_liquid_animation = value
	toast_new(e_toast.WARNING, text_get("alertreloadobjects"))
}
