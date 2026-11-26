function action_toolbar_build_mode()
{
	if (place_build)
	{
		action_build_first_person(false)
		app_place_stop()
	}
	else
	{
		build_type = e_tl_type.BLOCK
		app_place_start(true)
	}
}
