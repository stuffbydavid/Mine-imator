/// window_flash()

function window_flash()
{
	if (!is_cpp())
		return 0
	
	return external_call(lib_window_flash)
}