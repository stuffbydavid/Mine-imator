/// action_view_transform_mode(value)
/// @arg value

function action_view_transform_mode(value)
{
	if (window_busy = "rendercontrol")
		return 0

	setting_transform_mode = clamp(round(value), e_transform_mode.GIMBAL, e_transform_mode.amount - 1)
	view_transform_update_selection()
	return 0
}
