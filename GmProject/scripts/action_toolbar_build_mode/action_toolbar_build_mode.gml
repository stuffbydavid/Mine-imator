/// action_toolbar_build_mode()

function action_toolbar_build_mode()
{
	if (place_build)
		app_stop_place()
	else
	{
		build_type = e_tl_type.BLOCK
		app_start_place(true)
	}
}
