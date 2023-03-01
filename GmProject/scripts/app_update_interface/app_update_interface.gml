/// app_update_interface()

function app_update_interface()
{
	if (update_interface_wait)
	{
		interface_update_instant()
		update_interface_wait = false
	}
	
	if (window_height <= 900 || setting_interface_compact)
	{
		ui_large_height = 24
		ui_small_height = 20
		window_compact = true
	}
	else
	{
		ui_large_height = 32
		ui_small_height = 24
		window_compact = false
	}
	
	/*
	if (current_time < update_interface_timeout)
		interface_update()
	*/
}
