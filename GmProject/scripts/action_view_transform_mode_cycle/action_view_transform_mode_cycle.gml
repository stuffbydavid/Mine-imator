/// action_view_transform_mode_cycle()

function action_view_transform_mode_cycle()
{
	action_view_transform_mode((setting_transform_mode + 1) mod e_transform_mode.amount)
}
