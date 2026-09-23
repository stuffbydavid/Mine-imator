/// action_toolbar_build_mode()

function action_toolbar_build_mode()
{
	if (place_build)
	{
		action_build_first_person(false)
		app_stop_place()
	}
	else
	{
		build_type = e_tl_type.BLOCK
		app_start_place(true)
	}
}
