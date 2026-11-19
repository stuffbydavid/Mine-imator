/// @desc Advance queued loading and return whether more work is available.

function load_update()
{
	if (!load_active())
		return false
	
	var start = get_timer();
	do
	{
		popup_loading.load_wait = false
		with (popup_loading.load_object)
			script_execute(app.popup_loading.load_script)
		
		if (!load_active() || popup_loading.load_wait)
			return false
		
		if (is_cpp())
			return true
	}
	until (get_timer() - start >= 8000)
	
	return true
}